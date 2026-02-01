import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/core/constants/app_constants.dart';
import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/presentation/providers/auth_provider.dart';

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
  Timer? _navigationTimer;

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

  void _checkAuthStatus() {
    debugPrint('DEBUG [SplashScreen]: Checking auth status...');
    
    // Use a minimum splash time of 2 seconds
    final startTime = DateTime.now();
    
    Future.microtask(() async {
      await ref.read(authProvider.notifier).initialize();
      
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < const Duration(seconds: 2)) {
        await Future.delayed(const Duration(seconds: 2) - elapsed);
      }
      
      if (!mounted) return;
      
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      debugPrint('DEBUG [SplashScreen]: Is authenticated = $isAuthenticated');

      if (isAuthenticated) {
        debugPrint('DEBUG [SplashScreen]: >>> Navigating to HOME');
        context.go(AppRoutes.home);
      } else {
        debugPrint('DEBUG [SplashScreen]: >>> Navigating to LOGIN');
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Build better habits, every day',
                style: TextStyle(
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
