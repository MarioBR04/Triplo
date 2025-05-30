import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triplo/services/driver_service.dart';

void main() {
  group('DriverService Tests', () {
    test('mockDrivers should contain 3 drivers', () {
      expect(DriverService.mockDrivers.length, 3);
    });

    test('mockDrivers should have valid data', () {
      final driver = DriverService.mockDrivers.first;
      expect(driver.id, '1');
      expect(driver.name, 'John Doe');
      expect(driver.email, 'john@triplo.com');
      expect(driver.carInfo, 'Tesla Model 3 - White - SF123AB');
      expect(driver.currentLocation, const LatLng(37.7802, -122.4064));
      expect(driver.destination, const LatLng(37.7749, -122.4194));
      expect(driver.destinationName, 'San Francisco City Hall');
      expect(driver.rating, 4.8);
      expect(driver.isOnline, true);
    });

    test('getDriverMarkers should return markers for all online drivers', () {
      bool markerTapped = false;
      final markers = DriverService.getDriverMarkers((driver) {
        markerTapped = true;
      });

      expect(markers.length, 3); // Todos los conductores mock están online

      final firstMarker = markers.first;
      expect(firstMarker.markerId.value, '1');
      expect(firstMarker.position, const LatLng(37.7802, -122.4064));
      expect(firstMarker.infoWindow.title, 'John Doe');
      expect(
        firstMarker.infoWindow.snippet,
        'Destino: San Francisco City Hall',
      );
    });

    testWidgets('showDriverInfo should display driver information', (
      WidgetTester tester,
    ) async {
      final driver = DriverService.mockDrivers.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => DriverService.showDriverInfo(context, driver),
                  child: const Text('Show Info'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pumpAndSettle();

      expect(find.text(driver.name), findsOneWidget);
      expect(find.text('Vehículo: ${driver.carInfo}'), findsOneWidget);
      expect(find.text(' ${driver.rating}'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.text('Solicitar Viaje'), findsOneWidget);
    });
  });
}
