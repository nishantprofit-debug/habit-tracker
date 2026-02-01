import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/core/constants/app_constants.dart';
import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/core/theme/app_colors.dart';

/// Splash Screen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG [SplashScreen]: initState - Screen loaded');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    debugPrint('DEBUG [SplashScreen]: Animation started');

    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    debugPrint('DEBUG [SplashScreen]: Checking auth status...');
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final accessToken = prefs.getString(AppConstants.accessTokenKey);
    debugPrint('DEBUG [SplashScreen]: Token exists = ${accessToken != null && accessToken.isNotEmpty}');

    if (accessToken != null && accessToken.isNotEmpty) {
      // User is logged in
      debugPrint('DEBUG [SplashScreen]: >>> Navigating to HOME');
      context.go(AppRoutes.home);
    } else {
      // User needs to login
      debugPrint('DEBUG [SplashScreen]: >>> Navigating to LOGIN');
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'Habit Tracker',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                  letterSpacing: -0.5,
                ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Build better habits, every day',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


