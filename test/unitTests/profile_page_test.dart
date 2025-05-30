import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplo/pages/profile_page.dart';

void main() {
  testWidgets('ProfilePage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    expect(find.text('Mi Perfil'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('Can enter edit mode and save', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    expect(find.byIcon(Icons.edit), findsOneWidget);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, 'Nuevo Nombre');
    await tester.pump();
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('Shows validation error on empty phone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    expect(
      find.text('Por favor ingresa tu teléfono'),
      findsOneWidget,
    );
  });
}
