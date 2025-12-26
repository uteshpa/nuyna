// Widget test for nuyna app
//
// Tests the main application widget to ensure it renders correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuyna/main.dart';

void main() {
  testWidgets('App renders correctly with title', (WidgetTester tester) async {
    // Build the app wrapped in ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app title is displayed in the AppBar
    expect(find.text('nuyna'), findsOneWidget);

    // Verify that the welcome message is displayed
    expect(find.text("nuyna - Creator's Privacy Toolkit"), findsOneWidget);

    // Verify that the app uses Material 3 theme
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });

  testWidgets('MyHomePage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MyHomePage(title: 'Test Title'),
        ),
      ),
    );

    // Verify the title is displayed
    expect(find.text('Test Title'), findsOneWidget);

    // Verify the body text is displayed
    expect(find.text("nuyna - Creator's Privacy Toolkit"), findsOneWidget);

    // Verify it has an AppBar
    expect(find.byType(AppBar), findsOneWidget);

    // Verify it has a Scaffold
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
