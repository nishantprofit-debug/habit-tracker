import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/data/local/database_helper.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  debugPrint('==========================');
  debugPrint('  HABIT TRACKER APP START  ');
  debugPrint('==========================');

  WidgetsFlutterBinding.ensureInitialized();
  
  // Load env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Failed to load .env file: $e');
  }

  debugPrint('DEBUG: Flutter binding initialized');

  // Initialize Supabase
  debugPrint('DEBUG: Initializing Supabase...');
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    debugPrint('DEBUG: ✓ Supabase initialized successfully');
  } catch (e) {
    debugPrint('DEBUG: ✗ Supabase initialization failed: $e');
  }

  // Firebase removed in favor of Supabase
  debugPrint('DEBUG: Firebase initialization skipped (Removed)');

  // Initialize local database
  debugPrint('DEBUG: Initializing local database...');
  try {
    await DatabaseHelper.instance.database;
    debugPrint('DEBUG: ✓ Local database initialized successfully');
  } catch (e) {
    debugPrint('DEBUG: ✗ Local database initialization failed: $e');
  }

  // Initialize notifications
  debugPrint('DEBUG: Initializing notifications...');
  try {
    await NotificationService.instance.initialize();
    debugPrint('DEBUG: ✓ Notifications initialized successfully');
  } catch (e) {
    debugPrint('DEBUG: ✗ Notifications initialization failed: $e');
  }

  // Set system UI style
  debugPrint('DEBUG: Setting system UI style...');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  debugPrint('DEBUG: ✓ System UI style set');

  // Lock orientation to portrait
  debugPrint('DEBUG: Locking orientation to portrait...');
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('DEBUG: ✓ Orientation locked');

  debugPrint('DEBUG: Starting app...');
  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
  debugPrint('DEBUG: App started successfully!');
  debugPrint('==========================');
}

