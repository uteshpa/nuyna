import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/core/di/service_locator.dart';
import 'package:nuyna/main.dart';

void main() {
  setUpAll(() {
    setupLocator();
  });

  tearDownAll(() async {
    await resetLocator();
  });

  testWidgets('NuynaApp smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NuynaApp()));

    // Verify app starts with the home page
    expect(find.text('nuyna'), findsOneWidget);
    expect(find.text('Select Video'), findsOneWidget);
  });

  testWidgets('NuynaApp should display action buttons', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NuynaApp()));

    expect(find.text('METADATA'), findsOneWidget);
    expect(find.text('BIOMETRICS'), findsOneWidget);
    expect(find.text('FACE'), findsOneWidget);
  });
}
