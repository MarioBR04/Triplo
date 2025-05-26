import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:triplo/main.dart';
import '../Firebase/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupFirebaseTestMocks();
  });

  testWidgets('App Performance Test', (WidgetTester tester) async {
    // 1. Measure startup time
    final startupStopwatch = Stopwatch()..start();
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    startupStopwatch.stop();

    print('Startup time: ${startupStopwatch.elapsedMilliseconds}ms');
    expect(startupStopwatch.elapsedMilliseconds, lessThan(2000));

    // 2. Measure UI response time
    final navigationStopwatch = Stopwatch()..start();
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    navigationStopwatch.stop();

    print('UI response time: ${navigationStopwatch.elapsedMilliseconds}ms');
    expect(navigationStopwatch.elapsedMilliseconds, lessThan(300));

    // 3. Check frame build performance
    final frameBuildStopwatch = Stopwatch()..start();
    await tester.pumpAndSettle();
    frameBuildStopwatch.stop();

    print('Frame build time: ${frameBuildStopwatch.elapsedMilliseconds}ms');
    expect(
      frameBuildStopwatch.elapsedMilliseconds,
      lessThan(100),
      reason: 'Frame build time should be under 100ms',
    );

    // 4. Check for exceptions during test
    final didReportExceptions = tester.binding.takeException() != null;
    expect(didReportExceptions, false, reason: 'No exceptions during test');
  });
}
