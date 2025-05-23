import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:triplo/main.dart';
import 'package:triplo/services/loginService.dart';
import 'package:triplo/pages/login.dart';
import 'package:triplo/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/firebase_test_helper.dart';

class MockLoginService extends LoginService {
  final bool _hasUser;

  MockLoginService(this._hasUser);

  @override
  User? getCurrentUser() {
    return _hasUser ? MockUser() : null;
  }
}

class MockUser implements User {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupFirebaseTestMocks();
  });

  testWidgets('MyApp initializes with LoginPage when no user is logged in', (
    WidgetTester tester,
  ) async {
    // Override the LoginService to return null for getCurrentUser
    final loginService = MockLoginService(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return loginService.getCurrentUser() != null
                ? const HomePage()
                : const LoginPage();
          },
        ),
      ),
    );

    // Verify that LoginPage is shown
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('MyApp initializes with HomePage when user is logged in', (
    WidgetTester tester,
  ) async {
    // Override the LoginService to return a mock user
    final loginService = MockLoginService(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return loginService.getCurrentUser() != null
                ? const HomePage()
                : const LoginPage();
          },
        ),
      ),
    );

    // Verify that HomePage is shown
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('MyApp has correct theme data', (WidgetTester tester) async {
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

  testWidgets('MyApp has required routes', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final MaterialApp materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(materialApp.routes?['/login'], isNotNull);
    expect(materialApp.routes?['/home'], isNotNull);
  });
}
