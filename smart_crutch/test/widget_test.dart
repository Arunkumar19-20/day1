import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_crutch/main.dart';

void main() {
  testWidgets('SmartCrutch navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SmartCrutchApp());

    // Verify the Dashboard screen is shown by default
    expect(find.text('Smart Crutch — Dashboard'), findsOneWidget);

    // Tap the Alerts bottom navigation item
    await tester.tap(find.byIcon(Icons.warning));
    await tester.pumpAndSettle();

    // Verify that the Alerts screen is now visible
    expect(find.text('Safety Alerts'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify Settings screen is displayed
    expect(find.text('⚙️ Settings'), findsOneWidget);
  });
}
