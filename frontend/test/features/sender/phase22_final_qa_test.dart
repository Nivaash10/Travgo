import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_delivery_completion_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/repositories/sender_repository_factory.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/search_route_screen.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_feedback_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_status_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';
import 'package:frontend/features/sender/screens/sender_proof_viewer_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';

void main() {
  group('Phase 22 Comprehensive QA & Production Hardening Suite', () {
    tearDown(() {
      SenderRepositoryFactory.setUseRemote(false);
    });

    test('TASK 22.4 Status Consistency Across All Delivery Enums', () {
      const statuses = SenderDeliveryStatus.values;
      expect(statuses, containsAll([
        SenderDeliveryStatus.pending,
        SenderDeliveryStatus.accepted,
        SenderDeliveryStatus.rejected,
        SenderDeliveryStatus.cancelled,
        SenderDeliveryStatus.pickupPending,
        SenderDeliveryStatus.pickedUp,
        SenderDeliveryStatus.inTransit,
        SenderDeliveryStatus.delivered,
      ]));
    });

    test('TASK 22.6 Repository State & Fallback Safety', () async {
      final repo = MockSenderRepository();

      final bookings = await repo.getBookings();
      expect(bookings, isNotEmpty);

      final notifs = await repo.getNotifications();
      expect(notifs, isNotEmpty);

      final tracking = await repo.getTracking('BKG-101');
      expect(tracking, isNotNull);
      expect(tracking!.bookingId, equals('BKG-101'));

      final completion = await repo.getDeliveryCompletion('BKG-105');
      expect(completion, isNotNull);
      expect(completion!.bookingId, equals('BKG-105'));
    });

    testWidgets('TASK 22.3 & 22.5 Dashboard Entry Points & Layout QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));
      expect(find.text('TRAVGO'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('TASK 22.3 Search Route UI QA & Validation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SearchRouteScreen()));
      expect(find.text('Search Route'), findsOneWidget);

      await tester.tap(find.text('Find Travellers'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a source location'), findsOneWidget);
    });

    testWidgets('TASK 22.3 My Bookings Filter & Card QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: MyBookingsScreen()));
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('BKG-101'), findsOneWidget);
    });

    testWidgets('TASK 22.3 Booking Details Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final booking = SenderMockBookingData.getMockBookings().first;
      await tester.pumpWidget(MaterialApp(home: SenderBookingDetailScreen(booking: booking)));
      expect(find.text('Booking Details'), findsOneWidget);
    });

    testWidgets('TASK 22.3 Live Tracking Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderTrackingScreen(bookingId: 'BKG-103')));
      expect(find.text('Live Tracking'), findsOneWidget);
    });

    testWidgets('TASK 22.3 Delivery Completion Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderDeliveryCompletionScreen(bookingId: 'BKG-105')));
      expect(find.text('Delivery Status'), findsOneWidget);
    });

    testWidgets('TASK 22.3 Proof Viewer Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final completion = SenderMockDeliveryCompletionData.getCompletionForBooking('BKG-105');
      await tester.pumpWidget(MaterialApp(home: SenderProofViewerScreen(completion: completion)));
      expect(find.text('Proof of Delivery'), findsOneWidget);
    });

    testWidgets('TASK 22.3 Delivery Feedback Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final freshRating = SenderDeliveryRating(
        id: 'RAT-22',
        requestId: 'REQ-22',
        bookingId: 'BKG-22',
        travellerName: 'Arun Kumar',
        route: 'Coimbatore → Chennai',
        rating: 5.0,
        submittedAt: DateTime.now(),
        isSubmitted: false,
      );

      await tester.pumpWidget(MaterialApp(home: SenderDeliveryFeedbackScreen(ratingData: freshRating)));
      expect(find.text('Rate & Review'), findsOneWidget);

      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Review (5 Stars)');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
      expect(find.text('Thank You!'), findsOneWidget);
    });


    testWidgets('TASK 22.3 Notifications Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderNotificationsScreen()));
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('TASK 22.3 Delivery Status Screen QA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final booking = SenderMockBookingData.getMockBookings().first;
      final statusItem = SenderDeliveryStatusItem(
        requestId: 'REQ-101',
        request: booking.request,
        status: SenderDeliveryStatus.accepted,
        createdAt: DateTime.now(),
        pickupLocation: 'Coimbatore',
        deliveryLocation: 'Chennai',
      );

      await tester.pumpWidget(MaterialApp(home: SenderDeliveryStatusScreen(statusItem: statusItem)));
      expect(find.text('Delivery Status'), findsOneWidget);
    });
  });
}
