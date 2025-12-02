import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mine/main.dart'; // adjust path if needed

void main() {
  testWidgets('Supervisor page displays and adds worker', (WidgetTester tester) async {
    await tester.pumpWidget(MineBaseApp());

    // Verify SupervisorPage elements exist
    expect(find.text('Add Worker'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Name & Position fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Add Worker button

    // Enter worker details
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'Miner');

    // Tap Add Worker button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify the worker appears in the list
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Miner'), findsOneWidget);
  });

  testWidgets('Download consolidated CSV button exists', (WidgetTester tester) async {
    await tester.pumpWidget(MineBaseApp());

    // Verify the download button is present in AppBar
    expect(find.byIcon(Icons.download), findsOneWidget);
  });
}
