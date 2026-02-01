// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // REMOVED
// import 'package:google_sign_in/google_sign_in.dart'; // REMOVED
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final SupabaseClient _supabase = Supabase.instance.client;
  // GoogleSignIn and FirebaseAuth removed


  AuthNotifier() : super(const AuthState());

  /// Initialize auth state from storage
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final session = _supabase.auth.currentSession;

      if (session != null) {
        _apiClient.setAccessToken(session.accessToken);
        
        // Fetch user profile from our own backend/table if needed
        // Assuming Supabase user metadata is enough for basic info
        final user = session.user;
        
        // We might still want to fetch extended profile from our API
        // For now, let's construct UserModel from Supabase user
        // OR try to fetch from API using the new token
        
        try {
           final response = await _apiClient.get(ApiEndpoints.userProfile);
           if (response.statusCode == 200) {
             final userModel = UserModel.fromJson(response.data);
             state = state.copyWith(
                isLoading: false,
                isAuthenticated: true,
                user: userModel,
                // Tokens are managed by Supabase SDK mostly, but we keep state consistent
                tokens: AuthTokenModel(
                  accessToken: session.accessToken,
                  refreshToken: session.refreshToken ?? '',
                  expiresIn: 3600,
                  tokenType: 'Bearer',
                ),
             );
             return;
           }
        } catch (_) {
           // Fallback to basic user info if API fails (or if we need to create profile)
        }
                     
         state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
             // Create temporal user model from Supabase User
            user: UserModel(
              id: user.id,
              firebaseUid: user.id, // Map Supabase ID to firebaseUid field for compatibility
              email: user.email ?? '',
              displayName: user.email?.split('@')[0] ?? 'User',
              createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
              updatedAt: DateTime.now(),
            ),
         );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  /// Sign in with Google (Supabase)
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Supabase Google Auth
      // Note: This often requires deep linking setup on mobile.
      // For this text-only fix, we assume standard OAuth flow.
      final bool result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://callback',
      );
      
      if (!result) {
         throw Exception('Google Sign In initiated but failed to launch');
      }

      // The auth state change stream will handle the rest in a real Supabase app,
      // but here we might need to wait or rely on the stream listener. 
      // Supabase SDK maintains state. 
      // We will perform a manual check after a delay or return true and let the StreamBuilder handle it?
      // But this method returns Future<bool>. 
      
      // For the sake of this synchronous-looking interface:
      // We can't easily wait for the callback here without a deep link listener.
      // Assuming the UI handles the deep link.
      
      return true; 
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Email/Password (Supabase)
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final session = res.session;
      final user = res.user;

      if (session != null && user != null) {
         _apiClient.setAccessToken(session.accessToken);
         await initialize(); // Refresh state
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

  /// Register with Email/Password (Supabase)
  Future<bool> registerWithEmail(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );
      
      final session = res.session;
      final user = res.user;

      if (session != null && user != null) {
         _apiClient.setAccessToken(session.accessToken);
         await initialize();
         return true;
      }
      return false; // Might require email confirmation
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // _exchangeToken removed


  /// Sign out the user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _supabase.auth.signOut();

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

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
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

