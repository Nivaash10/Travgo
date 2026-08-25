import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/repositories/sender_repository_factory.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/search_route_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_feedback_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';
import 'package:frontend/features/sender/services/sender_api_service.dart';

void main() {
  group('Phase 20 Production Configuration & Security Safety Tests', () {
    tearDown(() {
      SenderRepositoryFactory.setUseRemote(false);
    });

    test('SenderApiService uses default base URL without hardcoded secrets or tokens', () {
      const apiService = SenderApiService();
      expect(apiService.baseUrl, equals('https://api.travgo.com/v1/sender'));
    });

    test('SenderRepositoryFactory safely handles environment switching', () {
      expect(SenderRepositoryFactory.isRemoteActive, isFalse);
      expect(SenderRepositoryFactory.createRepository(), isA<MockSenderRepository>());

      SenderRepositoryFactory.setUseRemote(true);
      expect(SenderRepositoryFactory.isRemoteActive, isTrue);
      expect(SenderRepositoryFactory.createRepository(), isA<RemoteSenderRepository>());
    });

    test('RemoteSenderRepository failure modes throw UnimplementedError gracefully without app crash', () async {
      final remoteRepo = RemoteSenderRepository();

      expect(() => remoteRepo.getBookings(), throwsUnimplementedError);
      expect(() => remoteRepo.getNotifications(), throwsUnimplementedError);
      expect(() => remoteRepo.getTracking('BKG-101'), throwsUnimplementedError);
    });
  });

  group('Phase 20 End-to-End Sender Module Smoke Tests', () {
    testWidgets('SenderDashboardScreen loads cleanly in production mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));
      expect(find.text('TRAVGO'), findsOneWidget);
    });

    testWidgets('SearchRouteScreen form input validation and flow regression test', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SearchRouteScreen()));
      expect(find.text('Search Route'), findsOneWidget);

      await tester.tap(find.text('Find Travellers'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a source location'), findsOneWidget);
    });

    testWidgets('MyBookingsScreen loads mock bookings list safely', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: MyBookingsScreen()));
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('BKG-101'), findsOneWidget);
    });

    testWidgets('SenderNotificationsScreen loads notification items cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MaterialApp(home: SenderNotificationsScreen()));
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('SenderDeliveryFeedbackScreen rating interaction regression test', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final freshRating = SenderDeliveryRating(
        id: 'RAT-NEW-20',
        requestId: 'REQ-20',
        bookingId: 'BKG-20',
        travellerName: 'Arun Kumar',
        route: 'Coimbatore → Chennai',
        rating: 5.0,
        submittedAt: DateTime.now(),
        isSubmitted: false,
      );

      await tester.pumpWidget(MaterialApp(
        home: SenderDeliveryFeedbackScreen(ratingData: freshRating),
      ));
      expect(find.text('Rate & Review'), findsOneWidget);

      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Review (5 Stars)');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
      expect(find.text('Thank You!'), findsOneWidget);
    });

  });
}
