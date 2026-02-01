import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/data/models/user_model.dart';

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
  AuthNotifier() : super(const AuthState());

  /// Initialize auth state from storage
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Load tokens from secure storage
      // TODO: Validate tokens and refresh if needed
      // TODO: Load user profile

      // For now, check if user was logged in
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in with Firebase token
  Future<bool> signIn({
    required String firebaseToken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call auth API to exchange Firebase token for app tokens
      // TODO: Store tokens in secure storage
      // TODO: Load user profile

      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful login
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: UserModel(
          id: 'user-123',
          firebaseUid: 'firebase-123',
          email: 'user@example.com',
          displayName: 'John Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        tokens: const AuthTokenModel(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          expiresIn: 3600,
          tokenType: 'Bearer',
        ),
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String firebaseToken,
    required String email,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call register API
      // TODO: Store tokens in secure storage
      // TODO: Load user profile

      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: UserModel(
          id: 'user-123',
          firebaseUid: 'firebase-123',
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        tokens: const AuthTokenModel(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          expiresIn: 3600,
          tokenType: 'Bearer',
        ),
      );

      return true;
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
      // TODO: Clear tokens from secure storage
      // TODO: Clear local database
      // TODO: Call logout API

      await Future.delayed(const Duration(milliseconds: 500));

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
      // TODO: Call update profile API

      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        isLoading: false,
        user: state.user!.copyWith(
          displayName: displayName ?? state.user!.displayName,
        ),
      );

      return true;
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

