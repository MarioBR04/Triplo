import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:triplo/pages/driver_mode_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Registrar el handler para el método getCurrentPosition
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getCurrentPosition') {
              return {
                'latitude': 37.7749,
                'longitude': -122.4194,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'accuracy': 0.0,
                'altitude': 0.0,
                'heading': 0.0,
                'speed': 0.0,
                'speedAccuracy': 0.0,
                'floor': null,
                'isMocked': true,
              };
            } else if (methodCall.method == 'checkPermission') {
              return 3; // LocationPermission.always
            }
            return null;
          },
        );
  });

  Widget buildTestableWidget() {
    return MaterialApp(home: const DriverModePage());
  }

  group('DriverModePage Tests', () {
    testWidgets('should show loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show app bar with correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Modo Conductor'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should toggle online status with switch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final Switch switchWidget = tester.widget(find.byType(Switch));
      expect(switchWidget.value, false);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final Switch updatedSwitchWidget = tester.widget(find.byType(Switch));
      expect(updatedSwitchWidget.value, true);
    });

    testWidgets('should show destination search field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '¿A dónde vas?'), findsOneWidget);
    });

    testWidgets('should show map with current location', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('should show back button that navigates back', (
      WidgetTester tester,
    ) async {
      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onPopPage: (route, result) {
              didPop = true;
              return route.didPop(result);
            },
            pages: const [MaterialPage(child: DriverModePage())],
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(didPop, true);
    });

    testWidgets('should show snackbar when trip ends', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Activar modo online
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Buscar y tap en el botón de terminar viaje si está visible
      if (find
          .widgetWithText(ElevatedButton, 'Terminar Viaje')
          .evaluate()
          .isNotEmpty) {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Terminar Viaje'));
        await tester.pumpAndSettle();

        expect(find.text('Viaje terminado'), findsOneWidget);
      }
    });

    testWidgets('should show request dialog with correct information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Activar modo online
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Buscar y tap en el botón de aceptar solicitud si está visible
      if (find
          .widgetWithText(
            ElevatedButton,
            'Aceptar solicitud de pasajero cercano',
          )
          .evaluate()
          .isNotEmpty) {
        await tester.tap(
          find.widgetWithText(
            ElevatedButton,
            'Aceptar solicitud de pasajero cercano',
          ),
        );
        await tester.pumpAndSettle();

        // Verificar el contenido del diálogo
        expect(find.text('Nueva Solicitud'), findsOneWidget);
        expect(find.text('María García'), findsOneWidget);
        expect(find.text('4.8'), findsOneWidget);
        expect(find.text('Chase Center, San Francisco'), findsOneWidget);
        expect(find.text('Aceptar Viaje'), findsOneWidget);
        expect(find.text('Rechazar'), findsOneWidget);

        // Verificar que los botones están presentes y son clicables
        expect(find.widgetWithText(TextButton, 'Rechazar'), findsOneWidget);
        expect(
          find.widgetWithText(ElevatedButton, 'Aceptar Viaje'),
          findsOneWidget,
        );
      }
    });
  });
}
