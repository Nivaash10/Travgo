import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/screens/search_route_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SearchRouteScreen(),
    );
  }

  testWidgets('TEST 1: Empty form submit shows all validation errors', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap Find Travellers with empty fields
    await tester.tap(find.text('Find Travellers'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a source location'), findsOneWidget);
    expect(find.text('Please enter a destination location'), findsOneWidget);
    expect(find.text('Please select a travel date'), findsOneWidget);
    expect(find.text('Please enter a valid parcel weight'), findsOneWidget);
  });

  testWidgets('TEST 2: Source and destination cannot be identical', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter identical source and destination
    await tester.enterText(find.byType(TextFormField).at(0), 'Coimbatore');
    await tester.enterText(find.byType(TextFormField).at(1), 'coimbatore');

    await tester.tap(find.text('Find Travellers'));
    await tester.pumpAndSettle();

    expect(find.text('Source and destination must be different'), findsOneWidget);
  });

  testWidgets('TEST 3: Weight = 0 or negative or non-numeric is rejected', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter weight = 0
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.tap(find.text('Find Travellers'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid parcel weight'), findsOneWidget);

    // Enter weight = -2.5
    await tester.enterText(find.byType(TextFormField).at(2), '-2.5');
    await tester.tap(find.text('Find Travellers'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid parcel weight'), findsOneWidget);

    // Enter weight = "abc"
    await tester.enterText(find.byType(TextFormField).at(2), 'abc');
    await tester.tap(find.text('Find Travellers'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid parcel weight'), findsOneWidget);
  });

  testWidgets('TEST 4: Valid form submission creates search query and shows confirmation', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Fill Source and Destination
    await tester.enterText(find.byType(TextFormField).at(0), 'Coimbatore');
    await tester.enterText(find.byType(TextFormField).at(1), 'Chennai');

    // Fill Weight
    await tester.enterText(find.byType(TextFormField).at(2), '2.5');

    // Tap Date Picker and select OK (today)
    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Tap Find Travellers
    await tester.tap(find.text('Find Travellers'));
    await tester.pumpAndSettle();

    // Verify snackbar confirmation appears
    expect(find.textContaining('Search criteria ready: Coimbatore to Chennai'), findsOneWidget);
  });
}
