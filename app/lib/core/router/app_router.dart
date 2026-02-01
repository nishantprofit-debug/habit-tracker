import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/presentation/screens/splash/splash_screen.dart';
import 'package:habit_tracker/presentation/screens/auth/login_screen.dart';
import 'package:habit_tracker/presentation/screens/auth/register_screen.dart';
import 'package:habit_tracker/presentation/screens/home/home_screen.dart';
import 'package:habit_tracker/presentation/screens/habits/habits_list_screen.dart';
import 'package:habit_tracker/presentation/screens/habits/add_habit_screen.dart';
import 'package:habit_tracker/presentation/screens/habits/habit_detail_screen.dart';
import 'package:habit_tracker/presentation/screens/calendar/calendar_screen.dart';
import 'package:habit_tracker/presentation/screens/reports/reports_list_screen.dart';
import 'package:habit_tracker/presentation/screens/reports/report_detail_screen.dart';
import 'package:habit_tracker/presentation/screens/revisions/revision_suggestions_screen.dart';
import 'package:habit_tracker/presentation/screens/settings/settings_screen.dart';
import 'package:habit_tracker/presentation/screens/main/main_screen.dart';

/// Route Names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String habits = '/habits';
  static const String addHabit = '/habits/add';
  static const String habitDetail = '/habits/:id';
  static const String calendar = '/calendar';
  static const String reports = '/reports';
  static const String reportDetail = '/reports/:id';
  static const String revisions = '/revisions';
  static const String settings = '/settings';
}

/// App Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.habits,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HabitsListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        path: AppRoutes.addHabit,
        builder: (context, state) => const AddHabitScreen(),
      ),
      GoRoute(
        path: '/habits/:id',
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitDetailScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return ReportDetailScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: AppRoutes.revisions,
        builder: (context, state) => const RevisionSuggestionsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

