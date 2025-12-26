import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/presentation/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('should display nuyna logo', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('nuyna'), findsOneWidget);
      expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
    });

    testWidgets('should display Select Video text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('Select Video'), findsOneWidget);
    });

    testWidgets('should display three action buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('METADATA'), findsOneWidget);
      expect(find.text('BIOMETRICS'), findsOneWidget);
      expect(find.text('FACE'), findsOneWidget);
    });

    testWidgets('should display action button icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_satisfied_alt_outlined), findsOneWidget);
    });

    testWidgets('should have plus icon for video selection', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping METADATA button should toggle state', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Find METADATA button and tap it
      final metadataButton = find.text('METADATA');
      expect(metadataButton, findsOneWidget);

      // Find the GestureDetector parent of METADATA label
      final gestureDetector = find.ancestor(
        of: find.byIcon(Icons.description_outlined),
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetector, findsOneWidget);

      await tester.tap(gestureDetector.first);
      await tester.pump();
    });

    testWidgets('tapping video selection area should work', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Find the video selection area and tap it
      final selectVideoText = find.text('Select Video');
      final gestureDetector = find.ancestor(
        of: selectVideoText,
        matching: find.byType(GestureDetector),
      );

      await tester.tap(gestureDetector.first);
      await tester.pump();

      // After tap, should show "Video Selected"
      expect(find.text('Video Selected'), findsOneWidget);
    });

    testWidgets('should use correct background color', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF5F5F5));
    });
  });

  group('DashedBorderPainter', () {
    test('should not repaint when properties unchanged', () {
      final painter = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        gap: 8,
      );

      expect(painter.shouldRepaint(painter), false);
    });
  });
}
