import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_delivery_request.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/screens/booking_confirmation_screen.dart';
import 'package:frontend/features/sender/screens/parcel_details_screen.dart';
import 'package:frontend/features/sender/screens/review_delivery_request_screen.dart';

void main() {
  final testQuery = SenderSearchQuery(
    source: 'Coimbatore',
    destination: 'Chennai',
    date: DateTime(2026, 8, 25),
    parcelWeightKg: 2.5,
  );

  final testTraveller = const SenderTravellerMatch(
    travellerName: 'Arun',
    isVerified: true,
    route: 'Coimbatore → Chennai',
    travelDateTime: '25 Aug 2026 • 8:30 AM',
    availableCapacityKg: 5.0,
    priceRupees: 100.0,
    rating: 4.7,
  );

  final testDeliveryRequest = SenderDeliveryRequest(
    searchQuery: testQuery,
    traveller: testTraveller,
    parcelDescription: 'Books and clothes',
    parcelWeightKg: 2.5,
    parcelCategory: 'Documents',
    specialInstructions: 'Handle with care',
  );

  group('ParcelDetailsScreen Tests', () {
    testWidgets('1 & 2: Renders selected traveller details and pre-fills search weight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ParcelDetailsScreen(
            searchQuery: testQuery,
            traveller: testTraveller,
          ),
        ),
      );

      expect(find.text('Arun'), findsOneWidget);
      expect(find.text('Coimbatore → Chennai'), findsOneWidget);
      expect(find.text('Travel: 25 Aug 2026 • 8:30 AM'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget); // Pre-filled weight
    });

    testWidgets('3: Empty description is rejected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ParcelDetailsScreen(
            searchQuery: testQuery,
            traveller: testTraveller,
          ),
        ),
      );

      final reviewButton = find.text('Review Delivery Request');
      await tester.ensureVisible(reviewButton);
      await tester.tap(reviewButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a parcel description'), findsOneWidget);
    });

    testWidgets('5 & 6: Invalid weight (0 or exceeding capacity) is rejected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ParcelDetailsScreen(
            searchQuery: testQuery,
            traveller: testTraveller,
          ),
        ),
      );

      final reviewButton = find.text('Review Delivery Request');

      // Enter description
      await tester.enterText(find.byType(TextFormField).at(0), 'Books');

      // Enter weight = 0
      await tester.enterText(find.byType(TextFormField).at(1), '0');
      await tester.ensureVisible(reviewButton);
      await tester.tap(reviewButton);
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid parcel weight'), findsOneWidget);

      // Enter weight exceeding traveller capacity (10 kg > 5.0 kg)
      await tester.enterText(find.byType(TextFormField).at(1), '10.0');
      await tester.ensureVisible(reviewButton);
      await tester.tap(reviewButton);
      await tester.pumpAndSettle();
      expect(find.text('Weight exceeds available capacity (5.0 kg)'), findsOneWidget);
    });

    testWidgets('7: Valid parcel details navigate to ReviewDeliveryRequestScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ParcelDetailsScreen(
            searchQuery: testQuery,
            traveller: testTraveller,
          ),
        ),
      );

      final reviewButton = find.text('Review Delivery Request');
      await tester.enterText(find.byType(TextFormField).at(0), 'Books and clothes');
      await tester.ensureVisible(reviewButton);
      await tester.tap(reviewButton);
      await tester.pumpAndSettle();

      expect(find.byType(ReviewDeliveryRequestScreen), findsOneWidget);
    });
  });

  group('ReviewDeliveryRequestScreen & BookingConfirmationScreen Tests', () {
    testWidgets('8 & 9: Review screen displays entered info and Back & Edit pops screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReviewDeliveryRequestScreen(
                      request: testDeliveryRequest,
                    ),
                  ),
                );
              },
              child: const Text('Go To Review'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go To Review'));
      await tester.pumpAndSettle();

      expect(find.text('Arun'), findsOneWidget);
      expect(find.text('Books and clothes'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('2.5 kg'), findsOneWidget);
      expect(find.text('Handle with care'), findsOneWidget);
      expect(find.text('₹100'), findsOneWidget);

      // Tap Back & Edit
      final backButton = find.text('Back & Edit');
      await tester.ensureVisible(backButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.byType(ReviewDeliveryRequestScreen), findsNothing);
    });

    testWidgets('10 & 11: Submit navigates to BookingConfirmationScreen displaying details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewDeliveryRequestScreen(
            request: testDeliveryRequest,
          ),
        ),
      );

      final submitButton = find.text('Submit Delivery Request');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(find.text('Delivery Request Submitted'), findsOneWidget);
      expect(find.text('Arun'), findsOneWidget);
      expect(find.text('Coimbatore → Chennai'), findsOneWidget);
      expect(find.text('2.5 kg'), findsOneWidget);
      expect(find.text('Back to Sender Dashboard'), findsOneWidget);
    });
  });
}
