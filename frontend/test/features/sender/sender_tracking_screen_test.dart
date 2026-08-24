import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_tracking_data.dart';
import 'package:frontend/features/sender/models/sender_tracking.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';
import 'package:frontend/features/sender/widgets/sender_tracking_route.dart';
import 'package:frontend/features/sender/widgets/sender_tracking_status_badge.dart';

void main() {
  final mockTrackings = SenderMockTrackingData.getMockTrackings();

  test('TEST 1: Tracking model can be created correctly', () {
    final now = DateTime.now();
    final tracking = SenderTracking(
      requestId: 'REQ-TEST',
      bookingId: 'BKG-TEST',
      currentStatus: SenderTrackingStatus.inTransit,
      statusMessage: 'Parcel in transit',
      source: 'Coimbatore',
      destination: 'Chennai',
      travellerName: 'Arun',
      travellerVerified: true,
      travelDateTime: 'Today • 8:30 AM',
      estimatedArrival: '6:00 PM',
      currentLocation: 'Salem Highway',
      lastUpdated: now,
      progressPercentage: 0.5,
    );

    expect(tracking.requestId, equals('REQ-TEST'));
    expect(tracking.bookingId, equals('BKG-TEST'));
    expect(tracking.currentStatus, equals(SenderTrackingStatus.inTransit));
    expect(tracking.source, equals('Coimbatore'));
    expect(tracking.destination, equals('Chennai'));
    expect(tracking.travellerName, equals('Arun'));
    expect(tracking.progressPercentage, equals(0.5));
  });

  test('TEST 2: copyWith() correctly updates tracking status', () {
    final now = DateTime.now();
    final tracking = SenderTracking(
      requestId: 'REQ-TEST',
      bookingId: 'BKG-TEST',
      currentStatus: SenderTrackingStatus.inTransit,
      statusMessage: 'Parcel in transit',
      source: 'Coimbatore',
      destination: 'Chennai',
      travellerName: 'Arun',
      travelDateTime: 'Today • 8:30 AM',
      lastUpdated: now,
    );

    final updated = tracking.copyWith(
      currentStatus: SenderTrackingStatus.delivered,
      statusMessage: 'Delivered to recipient',
      progressPercentage: 1.0,
    );

    expect(updated.requestId, equals('REQ-TEST'));
    expect(updated.currentStatus, equals(SenderTrackingStatus.delivered));
    expect(updated.statusMessage, equals('Delivered to recipient'));
    expect(updated.progressPercentage, equals(1.0));
  });

  testWidgets('TEST 3: Tracking screen displays source and destination', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final tracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.inTransit);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: tracking),
      ),
    );

    expect(find.text('Live Tracking'), findsOneWidget);
    expect(find.text('${tracking.source} → ${tracking.destination}'), findsOneWidget);
    expect(find.byType(SenderTrackingRoute), findsOneWidget);
  });

  testWidgets('TEST 4: Tracking screen displays traveller information', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final tracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.inTransit);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: tracking),
      ),
    );

    expect(find.text('Traveller: ${tracking.travellerName}'), findsOneWidget);
    expect(find.text(tracking.travelDateTime), findsOneWidget);
  });

  testWidgets('TEST 5: Current delivery status is displayed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final tracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.inTransit);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: tracking),
      ),
    );

    expect(find.byType(SenderTrackingStatusBadge), findsOneWidget);
    expect(find.text(tracking.statusMessage), findsOneWidget);
    expect(find.text(tracking.currentLocation!), findsWidgets);
  });

  testWidgets('TEST 6: Tracking timeline displays all expected events', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final tracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.inTransit);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: tracking),
      ),
    );

    expect(find.text('TRACKING TIMELINE'), findsOneWidget);
    for (final evt in tracking.events) {
      expect(find.text(evt.title), findsWidgets);
    }
  });

  testWidgets('TEST 7: Completed/current/upcoming timeline states are visually represented', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final tracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.inTransit);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: tracking),
      ),
    );

    // Verify icons are present for completed, current, and upcoming timeline events
    expect(find.byIcon(Icons.check), findsWidgets);
    expect(find.byIcon(Icons.navigation), findsWidgets);
  });

  testWidgets('TEST 8: Delivered status displays correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final deliveredTracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.delivered);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: deliveredTracking),
      ),
    );

    expect(find.text('Delivered'), findsWidgets);
    expect(find.text('Parcel successfully delivered to recipient.'), findsOneWidget);
  });

  testWidgets('TEST 9: Cancelled status displays correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final cancelledTracking = mockTrackings.firstWhere((t) => t.currentStatus == SenderTrackingStatus.cancelled);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(tracking: cancelledTracking),
      ),
    );

    expect(find.text('Cancelled'), findsWidgets);
    expect(find.text('Delivery request was cancelled.'), findsOneWidget);
  });

  testWidgets('TEST 10: Loading state displays correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SenderTrackingScreen(isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading tracking information...'), findsOneWidget);
  });

  testWidgets('TEST 11 & 12: Error state displays correctly and retry callback is triggered', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderTrackingScreen(
          errorMessage: 'Network error occurred',
          onRetry: () {
            retried = true;
          },
        ),
      ),
    );

    expect(find.text('Unable to load tracking information'), findsOneWidget);
    expect(find.text('Network error occurred'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(retried, isTrue);
  });

  testWidgets('TEST 13: Track Delivery navigation/entry point opens SenderTrackingScreen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final booking = SenderMockBookingData.getMockBookings().first;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderBookingDetailScreen(booking: booking),
      ),
    );

    final trackButton = find.text('Track Delivery');
    expect(trackButton, findsOneWidget);

    await tester.ensureVisible(trackButton);
    await tester.tap(trackButton);
    await tester.pumpAndSettle();

    expect(find.byType(SenderTrackingScreen), findsOneWidget);
  });
}
