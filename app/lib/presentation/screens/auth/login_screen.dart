import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/presentation/widgets/common/app_button.dart';
import 'package:habit_tracker/presentation/providers/auth_provider.dart';
import 'package:habit_tracker/presentation/widgets/common/app_text_field.dart';

/// Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG [LoginScreen]: Screen loaded');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    debugPrint('DEBUG [LoginScreen]: Screen disposed');
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint('DEBUG [LoginScreen]: Login button tapped');

    if (!_formKey.currentState!.validate()) {
      debugPrint('DEBUG [LoginScreen]: Form validation FAILED');
      return;
    }
    debugPrint('DEBUG [LoginScreen]: Form validation PASSED');

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text,
            _passwordController.text,
          );

      if (success && mounted) {
        debugPrint('DEBUG [LoginScreen]: Login SUCCESS - Navigating to HOME');
        context.go(AppRoutes.home);
      } else if (mounted) {
        final error = ref.read(authProvider).error ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('DEBUG [LoginScreen]: Login FAILED - Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('DEBUG [LoginScreen]: Google Sign In tapped');
    setState(() => _isLoading = true);
    
    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();
      
      if (success && mounted) {
        debugPrint('DEBUG [LoginScreen]: Google Login SUCCESS - Navigating to HOME');
        context.go(AppRoutes.home);
      } else if (mounted) {
        final error = ref.read(authProvider).error ?? 'Google login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('DEBUG [LoginScreen]: Google Login FAILED - Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Header
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue tracking your habits',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 48),

                // Email Field
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.grey500,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      debugPrint('DEBUG [LoginScreen]: Forgot password tapped');
                      // TODO: Navigate to forgot password
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                AppButton(
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 24),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.grey300)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.grey300)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In
                AppButton.outlined(
                  onPressed: _handleGoogleSignIn,
                  isLoading: _isLoading,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata, size: 24),
                      SizedBox(width: 8),
                      Text('Continue with Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Apple Sign In
                AppButton.outlined(
                  onPressed: () {
                    debugPrint('DEBUG [LoginScreen]: Apple Sign In tapped');
                    // TODO: Implement Apple Sign In
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 24),
                      SizedBox(width: 8),
                      Text('Continue with Apple'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    TextButton(
                      onPressed: () {
                        debugPrint('DEBUG [LoginScreen]: Sign Up tapped - Navigating to Register');
                        context.go(AppRoutes.register);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



