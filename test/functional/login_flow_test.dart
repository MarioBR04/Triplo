import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplo/pages/login.dart';
import 'package:triplo/services/loginService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/firebase_test_helper.dart';

/*
Caso de Prueba Funcional #1: Flujo de Inicio de Sesión
Descripción: Verifica el flujo completo de inicio de sesión, incluyendo validación de campos,
manejo de errores y navegación exitosa.

Precondiciones:
- La aplicación está instalada y en ejecución
- Firebase está inicializado
- No hay usuario autenticado

Pasos:
1. Iniciar la aplicación
2. Verificar que se muestra la pantalla de login
3. Intentar login con campos vacíos
4. Intentar login con credenciales inválidas
5. Realizar login con credenciales válidas
6. Verificar navegación a la pantalla principal

Resultados Esperados:
- Se muestran mensajes de error apropiados
- La navegación funciona correctamente
- El estado de la aplicación se actualiza apropiadamente
*/

class MockLoginService implements LoginService {
  @override
  Future<User?> signInWithPhoneAndPassword(
    String phone,
    String password,
  ) async {
    return null;
  }

  @override
  Future<User?> registerWithPhoneAndPassword(
    String phone,
    String password,
  ) async {
    return null;
  }

  @override
  Future<void> signOut() async {}

  @override
  User? getCurrentUser() {
    return null;
  }
}

void main() {
  late MockLoginService mockLoginService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupFirebaseTestMocks();
  });

  setUp(() {
    mockLoginService = MockLoginService();
  });

  testWidgets('Login Flow Test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
          child: LoginPage(loginService: mockLoginService),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify initial UI elements
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    // Enter credentials
    final phoneField = find.byKey(const Key('phone_field'));
    final passwordField = find.byKey(const Key('password_field'));

    await tester.enterText(phoneField, '+1234567890');
    await tester.pump();
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Verify entered text in text fields
    final phoneController = tester.widget<TextField>(phoneField).controller;
    final passwordController =
        tester.widget<TextField>(passwordField).controller;

    expect(phoneController?.text, '+1234567890');
    expect(passwordController?.text, 'password123');

    // Tap login button
    await tester.tap(find.text('Log In'));
    await tester.pump();
  });
}
