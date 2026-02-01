import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/data/local/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://cwjcfsnpqiyzluybmwxc.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3amNmc25wcWl5emx1eWJtd3hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NjEzMzAsImV4cCI6MjA4NTQzNzMzMH0.osaCK27a1ZlE6XUeEMTrKKpZH2o0uPtz2byslRCaz9s',
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase for now
  }

  // Initialize local database
  try {
    await DatabaseHelper.instance.database;
    debugPrint('Database initialized successfully');
  } catch (e) {
    debugPrint('Database initialization failed: $e');
  }

  // Initialize notifications
  try {
    await NotificationService.instance.initialize();
    debugPrint('Notifications initialized successfully');
  } catch (e) {
    debugPrint('Notifications initialization failed: $e');
  }

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}

