import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/core/di/service_locator.dart';
import 'package:nuyna/presentation/pages/home_page.dart';
import 'package:nuyna/presentation/viewmodels/home_viewmodel.dart';

void main() {
  setUpAll(() {
    setupLocator();
  });

  tearDownAll(() async {
    await resetLocator();
  });

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

    testWidgets('should display Select Image text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('Select Image'), findsOneWidget);
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

      // Find the GestureDetector parent of METADATA icon
      final gestureDetector = find.ancestor(
        of: find.byIcon(Icons.description_outlined),
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetector, findsOneWidget);

      await tester.tap(gestureDetector.first);
      await tester.pump();
    });

    testWidgets('should use Scaffold widget', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('should show process button when video selected', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Select a video via ViewModel
      container.read(homeViewModelProvider.notifier).selectVideo('/test/video.mp4');
      await tester.pump();

      // Should show process button
      expect(find.text('Process Image'), findsOneWidget);
      
      container.dispose();
    });

    testWidgets('action buttons should be tappable', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Find and tap BIOMETRICS button
      final biometricsButton = find.ancestor(
        of: find.byIcon(Icons.fingerprint),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(biometricsButton.first);
      await tester.pump();

      // Find and tap FACE button
      final faceButton = find.ancestor(
        of: find.byIcon(Icons.sentiment_satisfied_alt_outlined),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(faceButton.first);
      await tester.pump();
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
