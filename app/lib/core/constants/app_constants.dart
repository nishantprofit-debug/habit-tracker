/// App Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String lastSyncKey = 'last_sync';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Database
  static const String databaseName = 'habit_tracker.db';
  static const int databaseVersion = 1;

  // Sync
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Habit Categories
  static const List<String> habitCategories = [
    'learning',
    'health',
    'productivity',
    'personal',
  ];

  // Habit Icons
  static const List<String> habitIcons = [
    'check',
    'book',
    'fitness',
    'code',
    'brush',
    'music',
    'coffee',
    'run',
    'sleep',
    'meditation',
    'water',
    'food',
  ];
}
