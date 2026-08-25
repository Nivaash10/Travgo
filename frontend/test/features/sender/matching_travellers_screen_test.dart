import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/screens/matching_travellers_screen.dart';
import 'package:frontend/features/sender/widgets/sender_traveller_card.dart';

void main() {
  final testQuery = SenderSearchQuery(
    source: 'Coimbatore',
    destination: 'Chennai',
    date: DateTime(2026, 8, 25),
    parcelWeightKg: 2.5,
  );

  final sampleMatch1 = const SenderTravellerMatch(
    travellerName: 'Arun',
    isVerified: true,
    route: 'Coimbatore → Chennai',
    travelDateTime: '25 Aug 2026 • 8:30 AM',
    availableCapacityKg: 5.0,
    priceRupees: 100.0,
    rating: 4.7,
  );

  final sampleMatch2 = const SenderTravellerMatch(
    travellerName: 'Bala',
    isVerified: false,
    route: 'Coimbatore → Chennai',
    travelDateTime: '25 Aug 2026 • 2:00 PM',
    availableCapacityKg: 10.0,
    priceRupees: 200.0,
    rating: null,
  );

  testWidgets('TEST 1: Search summary displays source, destination, date and weight', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchingTravellersScreen(query: testQuery),
      ),
    );

    expect(find.text('From: Coimbatore'), findsOneWidget);
    expect(find.text('To: Chennai'), findsOneWidget);
    expect(find.text('Date: 25 Aug 2026'), findsOneWidget);
    expect(find.text('Weight: 2.5 kg'), findsOneWidget);
  });

  testWidgets('TEST 2: Empty traveller list displays "No travellers found" empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchingTravellersScreen(
          query: testQuery,
          travellerMatches: const [],
        ),
      ),
    );

    expect(find.text('No travellers found'), findsOneWidget);
    expect(find.text('Travellers matching your route will appear here.'), findsOneWidget);
    expect(find.text('Modify Search'), findsAtLeastNWidgets(1));
  });

  testWidgets('TEST 3: One supplied traveller match displays all card details correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchingTravellersScreen(
          query: testQuery,
          travellerMatches: [sampleMatch1],
        ),
      ),
    );

    expect(find.text('Arun'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Coimbatore → Chennai'), findsOneWidget);
    expect(find.text('25 Aug 2026 • 8:30 AM'), findsOneWidget);
    expect(find.text('5.0 kg'), findsOneWidget);
    expect(find.text('₹100'), findsOneWidget);
    expect(find.text('★ 4.7'), findsOneWidget);
    expect(find.text('Request Delivery'), findsOneWidget);
  });

  testWidgets('TEST 4: Multiple supplied traveller matches render all cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchingTravellersScreen(
          query: testQuery,
          travellerMatches: [sampleMatch1, sampleMatch2],
        ),
      ),
    );

    expect(find.byType(SenderTravellerCard), findsNWidgets(2));
    expect(find.text('Arun'), findsOneWidget);
    expect(find.text('Bala'), findsOneWidget);
    expect(find.text('No rating'), findsOneWidget);
  });

  testWidgets('TEST 5: Request Delivery callback triggers with selected match model', (tester) async {
    SenderTravellerMatch? selectedMatch;

    await tester.pumpWidget(
      MaterialApp(
        home: MatchingTravellersScreen(
          query: testQuery,
          travellerMatches: [sampleMatch1],
          onRequestDelivery: (match) {
            selectedMatch = match;
          },
        ),
      ),
    );

    await tester.tap(find.text('Request Delivery'));
    await tester.pumpAndSettle();

    expect(selectedMatch, equals(sampleMatch1));
  });

  testWidgets('TEST 6: Modify Search triggers callback / back behavior', (tester) async {
    bool modifyTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MatchingTravellersScreen(
          query: testQuery,
          travellerMatches: const [],
          onModifySearch: () {
            modifyTapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Modify Search'));
    await tester.pumpAndSettle();

    expect(modifyTapped, isTrue);
  });
}
