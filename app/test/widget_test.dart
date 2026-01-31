// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app.dart';

void main() {
  testWidgets('App initialization sanity test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: HabitTrackerApp(),
      ),
    );

    // Verify that the app title is present (as a placeholder check)
    // In a real app, you'd check for specific home screen widgets
    expect(find.byType(HabitTrackerApp), findsOneWidget);
  });
}
