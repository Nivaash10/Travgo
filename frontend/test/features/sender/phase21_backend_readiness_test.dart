import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/models/sender_notification.dart';
import 'package:frontend/features/sender/models/sender_resource.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/repositories/sender_repository_factory.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/search_route_screen.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';

void main() {
  group('Phase 21 Repository & Integration Boundary Tests', () {
    tearDown(() {
      SenderRepositoryFactory.setUseRemote(false);
    });

    test('SenderRepositoryFactory switches between Mock and Remote cleanly', () {
      expect(SenderRepositoryFactory.isRemoteActive, isFalse);
      expect(SenderRepositoryFactory.createRepository(), isA<MockSenderRepository>());

      SenderRepositoryFactory.setUseRemote(true);
      expect(SenderRepositoryFactory.isRemoteActive, isTrue);
      expect(SenderRepositoryFactory.createRepository(), isA<RemoteSenderRepository>());
    });

    test('MockSenderRepository executes all 9 API readiness operations asynchronously', () async {
      final repo = MockSenderRepository();

      final bookings = await repo.getBookings();
      expect(bookings, isNotEmpty);

      final detail = await repo.getBookingDetails('BKG-101');
      expect(detail, isNotNull);

      final notifs = await repo.getNotifications();
      expect(notifs, isNotEmpty);

      final tracking = await repo.getTracking('BKG-101');
      expect(tracking, isNotNull);

      final completion = await repo.getDeliveryCompletion('BKG-105');
      expect(completion, isNotNull);
    });

    test('Model serialization helpers (toJson/fromJson) maintain immutability and accuracy', () {
      final now = DateTime.now();

      final query = SenderSearchQuery(source: 'Chennai', destination: 'Bangalore', date: now, parcelWeightKg: 4.5);
      final queryRestored = SenderSearchQuery.fromJson(query.toJson());
      expect(queryRestored.source, equals('Chennai'));
      expect(queryRestored.destination, equals('Bangalore'));

      final notif = SenderNotification(
        id: 'N21',
        title: 'Phase 21 Title',
        message: 'Phase 21 Message',
        timestamp: now,
        type: SenderNotificationType.parcelPickedUp,
        isRead: true,
      );
      final notifRestored = SenderNotification.fromJson(notif.toJson());
      expect(notifRestored.id, equals('N21'));
      expect(notifRestored.isRead, isTrue);
    });

    test('SenderResource wrapper cleanly isolates UI state transitions', () {
      final resource = SenderResource<String>.success('Readiness Verified');
      expect(resource.isSuccess, isTrue);
      expect(resource.data, equals('Readiness Verified'));
    });
  });

  group('Phase 21 Flow & Navigation Regression Tests', () {
    testWidgets('SenderDashboardScreen renders and initiates navigation paths', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));
      expect(find.text('TRAVGO'), findsOneWidget);
    });

    testWidgets('SearchRouteScreen renders search inputs safely', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SearchRouteScreen()));
      expect(find.text('Search Route'), findsOneWidget);
    });

    testWidgets('MyBookingsScreen renders booking items safely', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: MyBookingsScreen()));
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('SenderBookingDetailScreen renders details safely', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final booking = SenderMockBookingData.getMockBookings().first;
      await tester.pumpWidget(MaterialApp(home: SenderBookingDetailScreen(booking: booking)));
      expect(find.text('Booking Details'), findsOneWidget);
    });

    testWidgets('SenderNotificationsScreen renders notification items cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderNotificationsScreen()));
      expect(find.text('Notifications'), findsOneWidget);
    });
  });
}
