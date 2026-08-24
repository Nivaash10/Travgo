import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/models/sender_booking.dart';
import 'package:frontend/features/sender/models/sender_delivery_request.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';
import 'package:frontend/features/sender/widgets/sender_booking_card.dart';

void main() {
  final mockBookings = SenderMockBookingData.getMockBookings();

  test('TEST 1: SenderBooking model can be created correctly', () {
    final now = DateTime.now();
    final booking = SenderBooking(
      id: 'BKG-TEST',
      status: SenderDeliveryStatus.pending,
      createdAt: now,
      deliveryPrice: 150.0,
      canCancel: true,
      canViewStatus: true,
      request: SenderDeliveryRequest(
        searchQuery: SenderSearchQuery(
          source: 'Coimbatore',
          destination: 'Chennai',
          date: now,
          parcelWeightKg: 2.0,
        ),
        traveller: const SenderTravellerMatch(
          travellerName: 'Arun',
          isVerified: true,
          route: 'Coimbatore → Chennai',
          travelDateTime: 'Today • 8:30 AM',
          availableCapacityKg: 5.0,
          priceRupees: 150.0,
          rating: 4.7,
        ),
        parcelDescription: 'Test Parcel',
        parcelWeightKg: 2.0,
        parcelCategory: 'Documents',
      ),
    );

    expect(booking.id, equals('BKG-TEST'));
    expect(booking.status, equals(SenderDeliveryStatus.pending));
    expect(booking.deliveryPrice, equals(150.0));
    expect(booking.canCancel, isTrue);
  });

  test('TEST 2: copyWith() works correctly', () {
    final now = DateTime.now();
    final booking = SenderBooking(
      id: 'BKG-TEST',
      status: SenderDeliveryStatus.pending,
      createdAt: now,
      deliveryPrice: 150.0,
      canCancel: true,
      canViewStatus: true,
      request: SenderDeliveryRequest(
        searchQuery: SenderSearchQuery(
          source: 'Coimbatore',
          destination: 'Chennai',
          date: now,
          parcelWeightKg: 2.0,
        ),
        traveller: const SenderTravellerMatch(
          travellerName: 'Arun',
          isVerified: true,
          route: 'Coimbatore → Chennai',
          travelDateTime: 'Today • 8:30 AM',
          availableCapacityKg: 5.0,
          priceRupees: 150.0,
          rating: 4.7,
        ),
        parcelDescription: 'Test Parcel',
        parcelWeightKg: 2.0,
        parcelCategory: 'Documents',
      ),
    );

    final cancelled = booking.copyWith(
      status: SenderDeliveryStatus.cancelled,
      canCancel: false,
    );

    expect(cancelled.id, equals('BKG-TEST'));
    expect(cancelled.status, equals(SenderDeliveryStatus.cancelled));
    expect(cancelled.canCancel, isFalse);
  });

  testWidgets('TEST 3 & 4: My Bookings screen displays booking cards and booking count', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: mockBookings),
      ),
    );

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('${mockBookings.length} total bookings'), findsOneWidget);
    expect(find.byType(SenderBookingCard), findsNWidgets(mockBookings.length));
  });

  testWidgets('TEST 5: All filter displays all bookings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: mockBookings),
      ),
    );

    expect(find.byType(SenderBookingCard), findsNWidgets(mockBookings.length));
  });

  testWidgets('TEST 6: Active filter excludes completed/cancelled bookings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: mockBookings),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Active'));
    await tester.pumpAndSettle();

    // Active includes accepted, pickupPending, inTransit (Bala, Karthik BKG-103, Karthik BKG-104)
    expect(find.text('BKG-102'), findsOneWidget);
    expect(find.text('BKG-103'), findsOneWidget);
    expect(find.text('BKG-104'), findsOneWidget);
    expect(find.text('BKG-101'), findsNothing); // Pending excluded
    expect(find.text('BKG-105'), findsNothing); // Delivered excluded
    expect(find.text('BKG-106'), findsNothing); // Cancelled excluded
  });

  testWidgets('TEST 7: Pending filter displays pending bookings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: mockBookings),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Pending'));
    await tester.pumpAndSettle();

    expect(find.text('BKG-101'), findsOneWidget);
    expect(find.text('BKG-102'), findsNothing);
  });

  testWidgets('TEST 8: Completed filter displays delivered/completed bookings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: mockBookings),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();

    expect(find.text('BKG-105'), findsOneWidget);
    expect(find.text('BKG-101'), findsNothing);
  });

  testWidgets('TEST 9: Cancelled filter displays cancelled bookings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: mockBookings),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Cancelled'));
    await tester.pumpAndSettle();

    expect(find.text('BKG-106'), findsOneWidget);
    expect(find.text('BKG-101'), findsNothing);
  });

  testWidgets('TEST 10: Empty booking list displays "No bookings yet"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyBookingsScreen(initialBookings: []),
      ),
    );

    expect(find.text('No bookings yet'), findsOneWidget);
    expect(find.text('Your delivery requests and bookings will appear here.'), findsOneWidget);
    expect(find.text('Create Delivery Request'), findsOneWidget);
  });

  testWidgets('TEST 11: Loading state displays CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyBookingsScreen(isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TEST 12: Error state displays error message and Try Again', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(
          errorMessage: 'Failed to load data',
          onRetry: () {
            retried = true;
          },
        ),
      ),
    );

    expect(find.text('Unable to load bookings'), findsOneWidget);
    expect(find.text('Failed to load data'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(retried, isTrue);
  });

  testWidgets('TEST 13: Tapping View Details opens SenderBookingDetailScreen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: [mockBookings.first]),
      ),
    );

    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    expect(find.byType(SenderBookingDetailScreen), findsOneWidget);
  });

  testWidgets('TEST 14: Tapping Track Delivery opens existing SenderDeliveryStatusScreen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderBookingDetailScreen(booking: mockBookings.first),
      ),
    );

    final trackButton = find.text('Track Delivery');
    expect(trackButton, findsOneWidget);
    await tester.ensureVisible(trackButton);
    await tester.tap(trackButton);
    await tester.pumpAndSettle();

    expect(find.byType(SenderTrackingScreen), findsOneWidget);
  });

  testWidgets('TEST 15, 16, 17: Cancel Request shows confirmation dialog, updates status and hides Cancel button', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MyBookingsScreen(initialBookings: [mockBookings.first]),
      ),
    );

    // TEST 15: Tap Cancel button
    final cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Cancel Delivery Request?'), findsOneWidget);
    expect(find.text('Are you sure you want to cancel this delivery request?'), findsOneWidget);
    expect(find.text('Keep Request'), findsOneWidget);

    // TEST 16: Confirm cancellation
    final confirmButton = find.widgetWithText(ElevatedButton, 'Cancel Request');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // TEST 17: Cancelled booking status updated and Cancel button removed
    expect(find.text('Cancelled'), findsAtLeastNWidgets(1));
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
  });

  testWidgets('TEST 18: Sender dashboard My Bookings entry point opens MyBookingsScreen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDashboardScreen(),
      ),
    );

    final myBookingsAction = find.text('My Bookings');
    expect(myBookingsAction, findsOneWidget);

    await tester.tap(myBookingsAction);
    await tester.pumpAndSettle();

    expect(find.byType(MyBookingsScreen), findsOneWidget);
  });
}
