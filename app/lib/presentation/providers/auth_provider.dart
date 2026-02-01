import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:habit_tracker/data/models/user_model.dart';
import 'package:habit_tracker/data/remote/api_client.dart';
import 'package:habit_tracker/core/constants/api_endpoints.dart';
import 'package:habit_tracker/core/constants/app_constants.dart';

/// Auth state for the application
class AuthState {
  final UserModel? user;
  final AuthTokenModel? tokens;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.tokens,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    AuthTokenModel? tokens,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient = ApiClient.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  AuthNotifier() : super(const AuthState());

  /// Initialize auth state from storage
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(AppConstants.accessTokenKey);
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);

      if (accessToken != null && refreshToken != null) {
        _apiClient.setAccessToken(accessToken);
        
        // Fetch user profile to validate token and get user data
        final response = await _apiClient.get(ApiEndpoints.userProfile);
        
        if (response.statusCode == 200) {
          final user = UserModel.fromJson(response.data);
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
            tokens: AuthTokenModel(
              accessToken: accessToken,
              refreshToken: refreshToken,
              expiresIn: 3600, // Dummy
              tokenType: 'Bearer',
            ),
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      // 2. Get credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Sign in to Firebase
      final firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase authentication failed');
      }

      // 4. Get Firebase ID token
      final String? idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // 5. Exchange for app token
      return await _exchangeToken(idToken, isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Email/Password (via Firebase)
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      return await _exchangeToken(idToken);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register with Email/Password (via Firebase)
  Future<bool> registerWithEmail(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(name);
      
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      return await _exchangeToken(idToken, isNewUser: true, name: name);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Exchange Firebase token for app tokens
  Future<bool> _exchangeToken(String firebaseToken, {bool isNewUser = false, String? name}) async {
    try {
      final endpoint = isNewUser ? ApiEndpoints.authRegister : ApiEndpoints.authLogin;
      final response = await _apiClient.post(
        endpoint,
        data: {
          'firebase_token': firebaseToken,
          if (isNewUser && name != null) 'display_name': name,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tokenResponse = AuthTokenResponse.fromJson(response.data);
        
        // Store tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.accessTokenKey, tokenResponse.accessToken);
        await prefs.setString(AppConstants.refreshTokenKey, tokenResponse.refreshToken);
        await prefs.setString(AppConstants.userIdKey, tokenResponse.user.id);

        _apiClient.setAccessToken(tokenResponse.accessToken);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: tokenResponse.user,
          tokens: AuthTokenModel(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresIn: tokenResponse.expiresIn,
            tokenType: tokenResponse.tokenType,
          ),
        );

        return true;
      } else {
        throw Exception('Failed to exchange tokens: ${response.data['message']}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign out the user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      // Clear tokens from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.accessTokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      await prefs.remove(AppConstants.userIdKey);

      _apiClient.clearAccessToken();

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? fcmToken,
  }) async {
    if (state.user == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.put(
        ApiEndpoints.userProfile,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(response.data);
        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience provider for getting current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

