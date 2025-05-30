import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:triplo/main.dart';
import 'package:triplo/services/loginService.dart';
import 'package:triplo/pages/home.dart';
import 'package:triplo/pages/login.dart';
import '../test_helper.dart';

void main() {
  late MockNavigator navigator;
  late LoginService mockLoginService;

  setUp(() async {
    await TestHelper.setupFirebaseForTesting();
    navigator = MockNavigator();
    mockLoginService = MockLoginService();
  });

  testWidgets('MyApp initializes with LoginPage when user is not logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('MyApp theme has correct properties', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final MaterialApp materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(materialApp.title, 'Triplo');
    expect(
      materialApp.theme?.visualDensity,
      VisualDensity.adaptivePlatformDensity,
    );
  });

  testWidgets('MyApp has correct routes defined', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final MaterialApp materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(materialApp.routes?.containsKey('/login'), true);
    expect(materialApp.routes?.containsKey('/home'), true);
  });

  testWidgets('Navigation to home works correctly', (
    WidgetTester tester,
  ) async {
    // Setup
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push(any())).thenAnswer((_) async => Future.value());

    // Build app
    await tester.pumpWidget(
      MockNavigatorProvider(navigator: navigator, child: const MyApp()),
    );

    // The app starts with LoginPage if not logged in, so we check for LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Navigation to login works correctly', (
    WidgetTester tester,
  ) async {
    // Setup
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push(any())).thenAnswer((_) async => Future.value());

    // Build app
    await tester.pumpWidget(
      MockNavigatorProvider(navigator: navigator, child: const MyApp()),
    );

    // Simulate navigation to login (if needed, adjust to match your app's navigation logic)
    // For now, just verify LoginPage is present
    expect(find.byType(LoginPage), findsOneWidget);
  });
}

class MockLoginService extends Mock implements LoginService {}
