import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_delivery_request.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/screens/booking_confirmation_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_status_screen.dart';
import 'package:frontend/features/sender/widgets/sender_delivery_status_badge.dart';
import 'package:frontend/features/sender/widgets/sender_delivery_timeline.dart';

void main() {
  final testRequest = SenderDeliveryRequest(
    searchQuery: SenderSearchQuery(
      source: 'Coimbatore',
      destination: 'Chennai',
      date: DateTime(2026, 8, 25),
      parcelWeightKg: 2.5,
    ),
    traveller: const SenderTravellerMatch(
      travellerName: 'Arun',
      isVerified: true,
      route: 'Coimbatore → Chennai',
      travelDateTime: '25 Aug 2026 • 8:30 AM',
      availableCapacityKg: 5.0,
      priceRupees: 100.0,
      rating: 4.7,
    ),
    parcelDescription: 'Books and documents',
    parcelWeightKg: 2.5,
    parcelCategory: 'Documents',
    specialInstructions: 'Handle with care',
  );

  final pendingStatusItem = SenderDeliveryStatusItem(
    requestId: 'REQ-101',
    request: testRequest,
    status: SenderDeliveryStatus.pending,
    createdAt: DateTime(2026, 8, 24),
  );

  final inTransitStatusItem = SenderDeliveryStatusItem(
    requestId: 'REQ-103',
    request: testRequest,
    status: SenderDeliveryStatus.inTransit,
    createdAt: DateTime(2026, 8, 24),
  );

  final deliveredStatusItem = SenderDeliveryStatusItem(
    requestId: 'REQ-104',
    request: testRequest,
    status: SenderDeliveryStatus.delivered,
    createdAt: DateTime(2026, 8, 24),
  );

  testWidgets('TEST 1: Status badge displays Pending correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SenderDeliveryStatusBadge(status: SenderDeliveryStatus.pending),
        ),
      ),
    );

    expect(find.text('Pending'), findsOneWidget);
    expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
  });

  testWidgets('TEST 2: Status badge displays In Transit correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SenderDeliveryStatusBadge(status: SenderDeliveryStatus.inTransit),
        ),
      ),
    );

    expect(find.text('In Transit'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
  });

  testWidgets('TEST 3: Delivery timeline renders the correct states', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SenderDeliveryTimeline(statusItem: inTransitStatusItem),
        ),
      ),
    );

    expect(find.text('Request Submitted'), findsOneWidget);
    expect(find.text('Traveller Accepted'), findsOneWidget);
    expect(find.text('In Transit'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
  });

  testWidgets('TEST 4, 5, 6: Delivery status screen displays traveller, parcel, route and price', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryStatusScreen(statusItem: pendingStatusItem),
      ),
    );

    // TEST 4: Traveller info
    expect(find.text('Arun'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    // TEST 5: Parcel info
    expect(find.text('Books and documents'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('2.5 kg'), findsOneWidget);
    expect(find.text('Handle with care'), findsOneWidget);

    // TEST 6: Route and price
    expect(find.text('Coimbatore → Chennai'), findsOneWidget);
    expect(find.text('₹100'), findsOneWidget);
  });

  testWidgets('TEST 12: BookingConfirmationScreen provides "View Delivery Status"', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BookingConfirmationScreen(request: testRequest),
      ),
    );

    final viewStatusButton = find.text('View Delivery Status');
    expect(viewStatusButton, findsOneWidget);

    await tester.ensureVisible(viewStatusButton);
    await tester.tap(viewStatusButton);
    await tester.pumpAndSettle();

    expect(find.byType(SenderDeliveryStatusScreen), findsOneWidget);
  });

  testWidgets('TEST 13: Pending request does NOT incorrectly display parcel as delivered', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryStatusScreen(statusItem: pendingStatusItem),
      ),
    );

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Waiting for traveller acceptance.'), findsOneWidget);
  });

  testWidgets('TEST 14: Delivered request displays the completed delivery state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryStatusScreen(statusItem: deliveredStatusItem),
      ),
    );

    expect(find.text('Delivered'), findsAtLeastNWidgets(1));
    expect(find.text('Parcel has been delivered successfully.'), findsOneWidget);
  });
}
