import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/main.dart';

void main() {
  testWidgets('App loads and shows Dashboard screen', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(OneHealthApp());

    // Verify that the app loaded and contains the title "OneHealth"
    expect(find.text('OneHealth'), findsOneWidget);

    // Verify that the Dashboard screen is visible
    expect(find.text('Dashboard'), findsOneWidget);

    // Simulate tapping the "Quick Log" floating action button
    await tester.tap(find.byIcon(Icons.add_location_alt));
    await tester.pumpAndSettle();

    // Confirm that we navigated to the Case Reporting screen
    expect(find.text('Case Reporting'), findsOneWidget);
  });
}
