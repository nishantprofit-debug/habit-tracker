/// API Endpoints Configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Supabase Configuration
  static const String supabaseUrl = 'https://cwjcfsnpqiyzluybmwxc.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3amNmc25wcWl5emx1eWJtd3hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NjEzMzAsImV4cCI6MjA4NTQzNzMzMH0.osaCK27a1ZlE6XUeEMTrKKpZH2o0uPtz2byslRCaz9s';
  
  // Supabase REST API endpoints
  static const String supabaseRest = '$supabaseUrl/rest/v1';
  static const String supabaseAuth = '$supabaseUrl/auth/v1';
  
  // Backend API URL (Go server on Render)
  static const String baseUrl = 'https://habit-tracker-s7er.onrender.com/api/v1';

  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authFcmToken = '/auth/fcm-token';

  // User
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  static const String userAccount = '/user/account';

  // Habits
  static const String habits = '/habits';
  static String habit(String id) => '/habits/$id';
  static String habitStreak(String id) => '/habits/$id/streak';

  // Logs
  static const String logs = '/logs';
  static const String logsToday = '/logs/today';
  static String logsByHabit(String habitId) => '/logs/habit/$habitId';
  static String logsCalendar(String month) => '/logs/calendar/$month';
  static String quickComplete(String habitId) => '/logs/quick-complete/$habitId';

  // Reports
  static const String reports = '/reports';
  static String report(String month) => '/reports/$month';
  static const String reportsGenerate = '/reports/generate';
  static const String reportsRegenerate = '/reports/regenerate';

  // Revisions
  static const String revisions = '/revisions';
  static String revisionAccept(String id) => '/revisions/$id/accept';
  static String revisionDecline(String id) => '/revisions/$id/decline';

  // Sync
  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncStatus = '/sync/status';
}
