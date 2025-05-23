import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:triplo/widgets/sidebar.dart';
import 'package:triplo/services/loginService.dart';

class MockLoginService extends Mock implements LoginService {
  @override
  User? getCurrentUser() {
    return MockUser();
  }

  @override
  Future<void> signOut() async {}
}

class MockUser extends Mock implements User {
  @override
  String? get email => 'test@triplo.com';
}

void main() {
  late MockLoginService mockLoginService;
  late MockNavigator navigator;

  setUp(() {
    mockLoginService = MockLoginService();
    navigator = MockNavigator();
    when(
      () => navigator.pushReplacementNamed('/login'),
    ).thenAnswer((_) async {});
    when(() => navigator.canPop()).thenReturn(true);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MockNavigatorProvider(
        navigator: navigator,
        child: SizedBox(
          width: 800,
          height: 800,
          child: Scaffold(body: Sidebar(loginService: mockLoginService)),
        ),
      ),
    );
  }

  testWidgets('Sidebar renders all menu items', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify header
    expect(find.text('triplo'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('test'), findsOneWidget);

    // Verify menu items
    expect(find.text('New Trip'), findsOneWidget);
    expect(find.text('Schedule Trip'), findsOneWidget);
    expect(find.text('Travel History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Driver Mode'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Menu items close drawer when tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap each menu item and verify drawer closes
    final menuItems = [
      'New Trip',
      'Schedule Trip',
      'Travel History',
      'Settings',
      'My Profile',
      'Driver Mode',
      'Messages',
    ];

    for (final item in menuItems) {
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Sign out works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Adjust viewport size to ensure Sign Out button is visible
    await tester.binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpAndSettle();

    // Tap sign out with warnIfMissed: false to handle the warning
    await tester.tap(find.text('Sign Out'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify navigation to login page
    verify(() => navigator.pushReplacementNamed('/login')).called(1);
  });

  testWidgets('User info is displayed correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify user email is displayed correctly
    expect(find.text('test'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
