import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplo/pages/travel_history_page.dart';

void main() {
  testWidgets('TravelHistoryPage renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TravelHistoryPage()));
    expect(find.text('Historial de Viajes'), findsOneWidget);
  });

  testWidgets('Shows trips', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TravelHistoryPage()));
    expect(find.byType(Card), findsNWidgets(2));
  });
}
