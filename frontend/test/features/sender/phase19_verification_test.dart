import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_delivery_completion_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/models/sender_notification.dart';
import 'package:frontend/features/sender/models/sender_resource.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/repositories/sender_repository_factory.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_feedback_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_status_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';
import 'package:frontend/features/sender/screens/sender_proof_viewer_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';
import 'package:frontend/features/sender/services/sender_service.dart';

void main() {
  group('Phase 19 End-to-End Architecture & Repository Verification', () {
    tearDown(() {
      SenderRepositoryFactory.setUseRemote(false);
    });

    test(
      'All 11 Sender flows execute via MockSenderRepository abstraction',
      () async {
        final repo = MockSenderRepository();

        // 1. Dashboard / Bookings list
        final bookings = await repo.getBookings();
        expect(bookings, isNotEmpty);

        // 2. Search Route / Travellers
        const query = SenderSearchQuery(
          source: 'Coimbatore',
          destination: 'Chennai',
        );
        final searchResults = await repo.searchTravellers(query);
        expect(searchResults, isNotEmpty);

        // 3. Booking Details
        final detail = await repo.getBookingDetails('BKG-101');
        expect(detail, isNotNull);

        // 4. Notifications
        final notifs = await repo.getNotifications();
        expect(notifs, isNotEmpty);

        // 5. Mark notification as read
        await repo.markNotificationAsRead('NOTIF-1');

        // 6. Live Tracking
        final tracking = await repo.getTracking('BKG-101');
        expect(tracking, isNotNull);

        // 7. Delivery Completion
        final completion = await repo.getDeliveryCompletion('BKG-105');
        expect(completion, isNotNull);

        // 8. Rating Submission
        final rating = SenderDeliveryRating(
          id: 'RAT-P19',
          requestId: 'REQ-P19',
          bookingId: 'BKG-105',
          travellerName: 'Arun',
          rating: 5.0,
          submittedAt: DateTime.now(),
        );
        final submittedRating = await repo.submitRating(rating);
        expect(submittedRating.isSubmitted, isTrue);
      },
    );

    test('DTO / JSON Mapping round-trip integrity test', () {
      final now = DateTime.now();

      // SenderSearchQuery
      final query = SenderSearchQuery(
        source: 'Coimbatore',
        destination: 'Chennai',
        date: now,
        parcelWeightKg: 3.0,
      );
      final queryJson = query.toJson();
      final queryRestored = SenderSearchQuery.fromJson(queryJson);
      expect(queryRestored.source, equals('Coimbatore'));
      expect(queryRestored.parcelWeightKg, equals(3.0));

      // SenderNotification
      final notif = SenderNotification(
        id: 'N-19',
        title: 'Title',
        message: 'Message',
        timestamp: now,
        type: SenderNotificationType.parcelDelivered,
        isRead: false,
      );
      final notifJson = notif.toJson();
      final notifRestored = SenderNotification.fromJson(notifJson);
      expect(notifRestored.id, equals('N-19'));
      expect(
        notifRestored.type,
        equals(SenderNotificationType.parcelDelivered),
      );

      // SenderDeliveryRating
      final rating = SenderDeliveryRating(
        id: 'R-19',
        requestId: 'REQ-19',
        bookingId: 'BKG-19',
        travellerName: 'Arun',
        rating: 4.8,
        feedback: 'Excellent service!',
        submittedAt: now,
        isSubmitted: true,
      );
      final ratingJson = rating.toJson();
      final ratingRestored = SenderDeliveryRating.fromJson(ratingJson);
      expect(ratingRestored.rating, equals(4.8));
      expect(ratingRestored.feedback, equals('Excellent service!'));
    });

    test('SenderResource state wrapper transition verification', () {
      final loading = SenderResource<String>.loading();
      expect(loading.isLoading, isTrue);

      final success = SenderResource<String>.success('Verified');
      expect(success.isSuccess, isTrue);
      expect(success.data, equals('Verified'));

      final error = SenderResource<String>.error('API Error');
      expect(error.isError, isTrue);
      expect(error.errorMessage, equals('API Error'));
    });

    test(
      'RemoteSenderRepository throws UnimplementedError cleanly for all 9 methods',
      () {
        final remoteRepo = RemoteSenderRepository();

        expect(() => remoteRepo.getBookings(), throwsUnimplementedError);
        expect(
          () => remoteRepo.getBookingDetails('BKG-1'),
          throwsUnimplementedError,
        );
        expect(() => remoteRepo.getNotifications(), throwsUnimplementedError);
        expect(
          () => remoteRepo.markNotificationAsRead('N-1'),
          throwsUnimplementedError,
        );
        expect(() => remoteRepo.getTracking('BKG-1'), throwsUnimplementedError);
        expect(
          () => remoteRepo.getDeliveryCompletion('BKG-1'),
          throwsUnimplementedError,
        );
        expect(
          () => remoteRepo.submitRating(
            SenderDeliveryRating(
              id: 'R-1',
              requestId: 'REQ-1',
              bookingId: 'BKG-1',
              travellerName: 'A',
              submittedAt: DateTime.now(),
            ),
          ),
          throwsUnimplementedError,
        );
        expect(
          () => remoteRepo.searchTravellers(const SenderSearchQuery()),
          throwsUnimplementedError,
        );
      },
    );

    test('SenderService correctly injects repository via factory', () {
      final service1 = SenderService();
      expect(service1.repository, isA<MockSenderRepository>());

      SenderRepositoryFactory.setUseRemote(true);
      final service2 = SenderService();
      expect(service2.repository, isA<RemoteSenderRepository>());
    });
  });

  group('Phase 19 End-to-End Screen Navigation & UI Hardening', () {
    testWidgets('SenderDashboardScreen renders and navigates safely', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));
      expect(find.text('TRAVGO'), findsOneWidget);
    });

    testWidgets('MyBookingsScreen renders booking items safely', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: MyBookingsScreen()));
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('SenderBookingDetailScreen renders booking details cleanly', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final booking = SenderMockBookingData.getMockBookings().first;
      await tester.pumpWidget(
        MaterialApp(home: SenderBookingDetailScreen(booking: booking)),
      );
      expect(find.text('Booking Details'), findsOneWidget);
    });

    testWidgets('SenderTrackingScreen renders live tracking timeline safely', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: SenderTrackingScreen(bookingId: 'BKG-103')),
      );
      expect(find.text('Live Tracking'), findsOneWidget);
    });

    testWidgets('SenderNotificationsScreen renders notification list safely', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: SenderNotificationsScreen()),
      );
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets(
      'SenderDeliveryCompletionScreen renders completion details safely',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1800));
        addTearDown(() async => await tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(
            home: SenderDeliveryCompletionScreen(bookingId: 'BKG-105'),
          ),
        );
        expect(find.text('Delivery Completed'), findsOneWidget);
      },
    );

    testWidgets('SenderProofViewerScreen renders digital signature safely', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final completion =
          SenderMockDeliveryCompletionData.getCompletionForBooking('BKG-105');
      await tester.pumpWidget(
        MaterialApp(home: SenderProofViewerScreen(completion: completion)),
      );
      expect(find.text('Proof of Delivery'), findsOneWidget);
    });

    testWidgets(
      'SenderDeliveryFeedbackScreen renders rate delivery interface safely',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1800));
        addTearDown(() async => await tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(
            home: SenderDeliveryFeedbackScreen(bookingId: 'BKG-105'),
          ),
        );
        expect(find.text('Rate & Review'), findsOneWidget);
      },
    );

    testWidgets('SenderDeliveryStatusScreen renders status timeline cleanly', (
      tester,
    ) async {
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

      await tester.pumpWidget(
        MaterialApp(home: SenderDeliveryStatusScreen(statusItem: statusItem)),
      );
      expect(find.text('Delivery Status'), findsOneWidget);
    });
  });
}
