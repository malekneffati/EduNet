// test/widget_test.dart
// Updated to test the actual app (smoke test for LoginView)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edunet/views/app.dart';  // Adjust import if needed to point to App

void main() {
  testWidgets('App smoke test - Shows LoginView', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: App(),
      ),
    );

    // Verify that LoginView elements are present (assuming not authenticated)
    expect(find.text('Bienvenue sur EduNet'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
    expect(find.text('Se connecter avec Google'), findsOneWidget);

    // Optionally, test tab switch
    await tester.tap(find.text('Inscription'));
    await tester.pump();
    // Add checks for register form if needed
  });
}