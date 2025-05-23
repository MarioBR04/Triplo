import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triplo/pages/home.dart';
import 'package:triplo/services/loginService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/firebase_test_helper.dart';

/*
Caso de Prueba Funcional #2: Solicitud de Viaje
Descripción: Verifica el flujo completo de solicitud de un viaje, incluyendo la selección
de destino, número de pasajeros y búsqueda de conductor.

Precondiciones:
- Usuario está autenticado
- La aplicación está en la pantalla principal
- Los servicios de localización están activos
- Hay conexión a internet

Pasos:
1. Cargar la pantalla principal
2. Verificar que el mapa se muestra correctamente
3. Ingresar destino
4. Ingresar número de pasajeros
5. Solicitar conductor
6. Verificar estado de búsqueda

Resultados Esperados:
- La interfaz responde correctamente a las interacciones
- Los campos de entrada funcionan correctamente
- El botón de búsqueda se activa/desactiva según corresponda
- Se muestra el estado de búsqueda de conductor
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

  testWidgets('Trip Request Flow Test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 800,
          height: 800,
          child: HomePage(loginService: mockLoginService),
        ),
      ),
    );

    // Initial frame should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for location permission and map to load
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify UI elements after loading
    expect(find.text('Where you going?'), findsOneWidget);
    expect(find.text('How many are you?'), findsOneWidget);
    expect(find.text('Find Driver'), findsOneWidget);

    // Enter destination
    await tester.enterText(
      find.byKey(const Key('destination_field')),
      'San Francisco Airport',
    );
    await tester.pump();
    expect(find.text('San Francisco Airport'), findsOneWidget);

    // Enter passenger count
    await tester.enterText(find.byKey(const Key('passenger_count_field')), '2');
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // Tap Find Driver button
    await tester.tap(find.text('Find Driver'));
    await tester.pump();
  });

  testWidgets('Trip Request Validation Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(
            width: 800,
            height: 800,
            child: HomePage(loginService: mockLoginService),
          ),
        ),
      ),
    );

    // Wait for initial animations
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Try to request without destination
    await tester.enterText(find.byKey(const Key('passenger_count_field')), '2');
    await tester.pump();
    await tester.tap(find.text('Find Driver'));
    await tester.pump();

    // Verify validation message
    expect(find.text('Please enter a destination'), findsOneWidget);

    // Clear previous error
    await tester.pump();

    // Try to request without passengers
    await tester.enterText(
      find.byKey(const Key('destination_field')),
      'San Francisco Airport',
    );
    await tester.enterText(find.byKey(const Key('passenger_count_field')), '');
    await tester.pump();
    await tester.tap(find.text('Find Driver'));
    await tester.pump();

    // Verify validation message
    expect(find.text('Please enter number of passengers'), findsOneWidget);
  });
}
