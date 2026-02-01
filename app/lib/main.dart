import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/data/local/database_helper.dart';

void main() async {
  debugPrint('==========================');
  debugPrint('  HABIT TRACKER APP START  ');
  debugPrint('==========================');

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('DEBUG: Flutter binding initialized');

  // Initialize Supabase
  debugPrint('DEBUG: Initializing Supabase...');
  try {
    await Supabase.initialize(
      url: 'https://cwjcfsnpqiyzluybmwxc.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3amNmc25wcWl5emx1eWJtd3hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NjEzMzAsImV4cCI6MjA4NTQzNzMzMH0.osaCK27a1ZlE6XUeEMTrKKpZH2o0uPtz2byslRCaz9s',
    );
    debugPrint('DEBUG: ✓ Supabase initialized successfully');
  } catch (e) {
    debugPrint('DEBUG: ✗ Supabase initialization failed: $e');
  }

  // Initialize Firebase (with error handling)
  debugPrint('DEBUG: Initializing Firebase...');
  try {
    await Firebase.initializeApp();
    debugPrint('DEBUG: ✓ Firebase initialized successfully');
  } catch (e) {
    debugPrint('DEBUG: ✗ Firebase initialization failed: $e');
    debugPrint('DEBUG: Continuing without Firebase');
    // Continue without Firebase for now
  }

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

