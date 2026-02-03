import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillwalks/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Creating a proper integration test with all providers mocked
    // would be complex for this simple verification. 
    // For now, we simply ensure the app widget constructs without error.
    await tester.pumpWidget(const StillwalksApp());
    
    // Verify that the app tries to show the initializer
    expect(find.byType(AppInitializer), findsOneWidget);
  });
}
