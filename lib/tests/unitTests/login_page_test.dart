import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../pages/login.dart';
import '../../services/loginService.dart';

class MockLoginService implements LoginService {
  final calls = <String, List<List<dynamic>>>{};

  @override
  Future<User?> signInWithPhoneAndPassword(
    String phone,
    String password,
  ) async {
    calls['signInWithPhoneAndPassword'] =
        calls['signInWithPhoneAndPassword'] ?? [];
    calls['signInWithPhoneAndPassword']!.add([phone, password]);
    return null;
  }

  @override
  Future<User?> registerWithPhoneAndPassword(
    String phone,
    String password,
  ) async {
    calls['registerWithPhoneAndPassword'] =
        calls['registerWithPhoneAndPassword'] ?? [];
    calls['registerWithPhoneAndPassword']!.add([phone, password]);
    return null;
  }

  @override
  Future<void> signOut() async {}

  @override
  User? getCurrentUser() {
    return null;
  }

  void verify(String methodName, {int times = 1}) {
    final methodCalls = calls[methodName] ?? [];
    if (methodCalls.length != times) {
      throw TestFailure(
        'Expected $methodName to be called $times times but was called ${methodCalls.length} times',
      );
    }
  }

  List<List<dynamic>> getMethodCalls(String methodName) {
    return calls[methodName] ?? [];
  }
}

class MockUser extends Mock implements User {}

void main() {
  late MockLoginService mockLoginService;

  setUp(() {
    mockLoginService = MockLoginService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: LoginPage(loginService: mockLoginService));
  }

  testWidgets('LoginPage renders phone, password fields and buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });

  testWidgets('Register calls registerWithPhoneAndPassword', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextField).at(0), '+1234567890');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Create new account'));
    await tester.pump();

    mockLoginService.verify('registerWithPhoneAndPassword');
    final calls = mockLoginService.getMethodCalls(
      'registerWithPhoneAndPassword',
    );
    expect(calls.length, 1);
    expect(calls[0][0], '+1234567890');
    expect(calls[0][1], 'password123');
  });

  testWidgets('Login calls signInWithPhoneAndPassword', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).at(0), '+1234567890');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    mockLoginService.verify('signInWithPhoneAndPassword');
    final calls = mockLoginService.getMethodCalls('signInWithPhoneAndPassword');
    expect(calls.length, 1);
    expect(calls[0][0], '+1234567890');
    expect(calls[0][1], 'password123');
  });

  testWidgets('Shows error message when fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Please enter both phone and password'), findsOneWidget);
  });
}
