import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_delivery_request.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/models/sender_mock_delivery_data.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_requests_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_status_screen.dart';
import 'package:frontend/features/sender/widgets/sender_delivery_request_card.dart';
import 'package:frontend/features/sender/widgets/sender_delivery_status_badge.dart';

void main() {
  final mockRequests = SenderMockDeliveryData.getMockDeliveryRequests();

  testWidgets(
    'TEST 1 & 2: My Bookings screen renders and displays mock delivery requests',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: SenderDeliveryRequestsScreen(items: mockRequests)),
      );

      expect(find.text('My Bookings'), findsOneWidget);
      expect(
        find.byType(SenderDeliveryRequestCard),
        findsNWidgets(mockRequests.length),
      );
    },
  );

  testWidgets(
    'TEST 3 & 4: Route, traveller info, and status badge are displayed correctly',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: SenderDeliveryRequestsScreen(items: [mockRequests.first]),
        ),
      );

      expect(find.text('Arun'), findsOneWidget);
      expect(find.text('Coimbatore → Chennai'), findsOneWidget);
      expect(find.byType(SenderDeliveryStatusBadge), findsWidgets);
    },
  );

  testWidgets('TEST 5: Filtering to Active works', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: SenderDeliveryRequestsScreen(items: mockRequests)),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Active'));
    await tester.pumpAndSettle();

    // Active includes accepted, inTransit (Bala, Karthik)
    expect(find.text('Bala'), findsOneWidget);
    expect(find.text('Karthik'), findsOneWidget);
    expect(find.text('Arun'), findsNothing);
  });

  testWidgets('TEST 6: Filtering to Pending works', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: SenderDeliveryRequestsScreen(items: mockRequests)),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Pending'));
    await tester.pumpAndSettle();

    expect(find.text('Arun'), findsOneWidget);
    expect(find.text('Bala'), findsNothing);
  });

  testWidgets('TEST 7: Filtering to Completed works', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: SenderDeliveryRequestsScreen(items: mockRequests)),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();

    // Completed includes delivered (Ravi) and rejected (Suresh)
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('Suresh'), findsOneWidget);
    expect(find.text('Arun'), findsNothing);
  });

  testWidgets('TEST 8: Tapping a booking opens SenderDeliveryStatusScreen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryRequestsScreen(items: [mockRequests.first]),
      ),
    );

    await tester.tap(find.byType(SenderDeliveryRequestCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(SenderDeliveryStatusScreen), findsOneWidget);
  });

  testWidgets('TEST 9: Empty booking list displays "No bookings yet"', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SenderDeliveryRequestsScreen(items: [])),
    );

    expect(find.text('No bookings yet'), findsOneWidget);
    expect(
      find.text('Your delivery requests will appear here.'),
      findsOneWidget,
    );
    expect(find.text('Search Travellers'), findsOneWidget);
  });

  testWidgets('TEST 10: Search Travellers action from empty state works', (
    tester,
  ) async {
    bool searchTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryRequestsScreen(
          items: const [],
          onSearchTravellers: () {
            searchTapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Search Travellers'));
    await tester.pumpAndSettle();

    expect(searchTapped, isTrue);
  });

  testWidgets('TEST 11: Dashboard "My Bookings" opens MyBookingsScreen', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));

    final myBookingsAction = find.text('My Bookings');
    expect(myBookingsAction, findsOneWidget);

    await tester.tap(myBookingsAction);
    await tester.pumpAndSettle();

    expect(find.byType(MyBookingsScreen), findsOneWidget);
  });

  testWidgets(
    'TEST 12: Dashboard Recent Bookings displays mock preview data when available',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));

      expect(find.text('Recent Bookings'), findsOneWidget);
      expect(find.text('Coimbatore → Chennai'), findsWidgets);
      expect(find.text('Arun'), findsWidgets);
    },
  );

  testWidgets(
    'TEST 13: All supported delivery statuses render without crashing',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final now = DateTime.now();
      final allStatuses = SenderDeliveryStatus.values.map((s) {
        return SenderDeliveryStatusItem(
          requestId: 'REQ-${s.name}',
          status: s,
          createdAt: now,
          request: SenderDeliveryRequest(
            searchQuery: SenderSearchQuery(
              source: 'Coimbatore',
              destination: 'Chennai',
              date: now,
              parcelWeightKg: 1.0,
            ),
            traveller: SenderTravellerMatch(
              travellerName: 'TestTraveller_${s.name}',
              isVerified: true,
              route: 'Coimbatore → Chennai',
              travelDateTime: 'Today • 10:00 AM',
              availableCapacityKg: 5.0,
              priceRupees: 100.0,
              rating: 4.5,
            ),
            parcelDescription: 'Test parcel',
            parcelWeightKg: 1.0,
            parcelCategory: 'Documents',
          ),
        );
      }).toList();

      await tester.pumpWidget(
        MaterialApp(home: SenderDeliveryRequestsScreen(items: allStatuses)),
      );

      expect(
        find.byType(SenderDeliveryRequestCard),
        findsNWidgets(allStatuses.length),
      );
    },
  );
}
