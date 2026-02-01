// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    
    // Initialize Supabase with dummy values for testing
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'dummy-key-for-testing',
    );
  });

  testWidgets('App initialization sanity test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: HabitTrackerApp(),
      ),
    );

    // Verify that the app is created
    expect(find.byType(HabitTrackerApp), findsOneWidget);

    // Pump frames to allow the splash screen to initialize
    await tester.pump();

    // Wait for the splash screen timer (2 seconds) and navigation
    await tester.pump(const Duration(seconds: 2));

    // Pump one more frame to complete the navigation
    await tester.pump();
  });
}
