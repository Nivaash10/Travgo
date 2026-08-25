import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';
import 'package:frontend/features/sender/services/sender_api_service.dart';
import 'package:frontend/features/sender/services/sender_service.dart';

void main() {
  group('Phase 14 Serialization Tests', () {
    test('SenderSearchQuery supports toJson and fromJson', () {
      final now = DateTime.now();
      final query = SenderSearchQuery(
        source: 'Coimbatore',
        destination: 'Chennai',
        date: now,
        parcelWeightKg: 2.5,
      );

      final json = query.toJson();
      expect(json['source'], equals('Coimbatore'));
      expect(json['destination'], equals('Chennai'));
      expect(json['parcelWeightKg'], equals(2.5));

      final restored = SenderSearchQuery.fromJson(json);
      expect(restored.source, equals('Coimbatore'));
      expect(restored.destination, equals('Chennai'));
      expect(restored.parcelWeightKg, equals(2.5));
    });

    test('SenderDeliveryRating supports toJson and fromJson', () {
      final now = DateTime.now();
      final rating = SenderDeliveryRating(
        id: 'RAT-101',
        requestId: 'REQ-101',
        bookingId: 'BKG-101',
        travellerName: 'Arun',
        route: 'Coimbatore → Chennai',
        rating: 4.5,
        feedback: 'Super fast handover!',
        submittedAt: now,
        isSubmitted: true,
      );

      final json = rating.toJson();
      expect(json['id'], equals('RAT-101'));
      expect(json['rating'], equals(4.5));
      expect(json['feedback'], equals('Super fast handover!'));

      final restored = SenderDeliveryRating.fromJson(json);
      expect(restored.id, equals('RAT-101'));
      expect(restored.rating, equals(4.5));
      expect(restored.feedback, equals('Super fast handover!'));
      expect(restored.isSubmitted, isTrue);
    });
  });

  group('Phase 14 Repository & Service Abstraction Tests', () {
    test('MockSenderRepository returns bookings asynchronously', () async {
      final repo = MockSenderRepository();
      final bookings = await repo.getBookings();

      expect(bookings, isNotEmpty);
      expect(bookings.first.id, equals('BKG-101'));
    });

    test('MockSenderRepository returns notifications asynchronously', () async {
      final repo = MockSenderRepository();
      final notifications = await repo.getNotifications();

      expect(notifications, isNotEmpty);
    });

    test('MockSenderRepository returns tracking asynchronously', () async {
      final repo = MockSenderRepository();
      final tracking = await repo.getTracking('BKG-101');

      expect(tracking, isNotNull);
      expect(tracking?.bookingId, equals('BKG-101'));
    });

    test('MockSenderRepository returns completion asynchronously', () async {
      final repo = MockSenderRepository();
      final completion = await repo.getDeliveryCompletion('BKG-105');

      expect(completion, isNotNull);
      expect(completion?.bookingId, equals('BKG-105'));
    });

    test('MockSenderRepository submits rating asynchronously', () async {
      final repo = MockSenderRepository();
      final rating = SenderDeliveryRating(
        id: 'RAT-NEW',
        requestId: 'REQ-NEW',
        bookingId: 'BKG-105',
        travellerName: 'Ravi',
        rating: 5.0,
        submittedAt: DateTime.now(),
      );

      final result = await repo.submitRating(rating);
      expect(result.isSubmitted, isTrue);
      expect(result.rating, equals(5.0));
    });

    test('RemoteSenderRepository throws UnimplementedError with Person 1 TODOs', () {
      final repo = RemoteSenderRepository();
      expect(() => repo.getBookings(), throwsUnimplementedError);
      expect(() => repo.getNotifications(), throwsUnimplementedError);
    });

    test('SenderApiService throws UnimplementedError with Person 1 TODOs', () {
      const service = SenderApiService();
      expect(() => service.fetchBookingsJson(), throwsUnimplementedError);
      expect(() => service.fetchNotificationsJson(), throwsUnimplementedError);
    });

    test('SenderService correctly initializes with default MockSenderRepository', () {
      final service = SenderService();
      expect(service.repository, isA<MockSenderRepository>());
      expect(service.apiService, isA<SenderApiService>());
    });
  });

  group('Phase 14 UI State Readiness & Compatibility Tests', () {
    testWidgets('Loading state renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SenderDeliveryCompletionScreen(isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Error state renders error message and retry button', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SenderTrackingScreen(
            errorMessage: 'Network error occurred',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Network error occurred'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });

    testWidgets('SenderDashboardScreen renders and connects to navigation flows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: SenderDashboardScreen(),
        ),
      );

      expect(find.text('TRAVGO'), findsOneWidget);
      expect(find.text('Search Travellers'), findsWidgets);
    });
  });
}
