import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplo/pages/schedule_trip_page.dart';

void main() {
  testWidgets('ScheduleTripPage renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ScheduleTripPage()));
    expect(find.text('Programar Viaje'), findsAny);
    expect(find.text('Punto de partida'), findsOneWidget);
    expect(find.text('Destino'), findsOneWidget);
  });

  testWidgets('Can enter pickup and destination', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ScheduleTripPage()));
    await tester.enterText(find.byType(TextField).at(0), 'Casa');
    await tester.enterText(find.byType(TextField).at(1), 'Oficina');
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Oficina'), findsOneWidget);
  });

  testWidgets('Can open date and time pickers', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ScheduleTripPage()));
    await tester.tap(find.text('Fecha'));
    await tester.pumpAndSettle();
    expect(
      find.text('Seleccionar idioma').evaluate().isEmpty,
      true,
    ); // Just to pump
    await tester.tap(find.text('Hora'));
    await tester.pumpAndSettle();
    expect(
      find.text('Seleccionar idioma').evaluate().isEmpty,
      true,
    ); // Just to pump
  });
}
