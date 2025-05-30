import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplo/pages/settings_page.dart';

void main() {
  testWidgets('SettingsPage renders and toggles switches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(find.byType(Switch), findsNWidgets(2));
  });

  testWidgets('Can change language', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.tap(find.text('Idioma'));
    await tester.pumpAndSettle();
    expect(find.text('Seleccionar idioma'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('Can open About dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.tap(find.text('Acerca de'));
    await tester.pumpAndSettle();
    expect(find.text('Triplo'), findsOneWidget);
  });
}
