import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data_sources/sender_data_source.dart';
import 'package:frontend/features/sender/models/sender_resource.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';

void main() {
  group('Phase 15 Data Source Abstraction Tests', () {
    test('SenderMockDataSource fetches raw mock bookings', () async {
      const dataSource = SenderMockDataSource();
      final bookingsRaw = await dataSource.fetchBookingsRaw();

      expect(bookingsRaw, isNotEmpty);
      expect(bookingsRaw.first['id'], equals('BKG-101'));
    });

    test('SenderMockDataSource fetches raw booking details', () async {
      const dataSource = SenderMockDataSource();
      final detailRaw = await dataSource.fetchBookingDetailsRaw('BKG-101');

      expect(detailRaw, isNotNull);
      expect(detailRaw!['id'], equals('BKG-101'));
    });

    test('SenderMockDataSource fetches raw notifications', () async {
      const dataSource = SenderMockDataSource();
      final notificationsRaw = await dataSource.fetchNotificationsRaw();

      expect(notificationsRaw, isNotEmpty);
    });

    test('SenderMockDataSource fetches raw tracking data', () async {
      const dataSource = SenderMockDataSource();
      final trackingRaw = await dataSource.fetchTrackingRaw('BKG-101');

      expect(trackingRaw, isNotNull);
      expect(trackingRaw!['bookingId'], equals('BKG-101'));
    });

    test('SenderMockDataSource fetches raw completion data', () async {
      const dataSource = SenderMockDataSource();
      final completionRaw = await dataSource.fetchCompletionRaw('BKG-105');

      expect(completionRaw, isNotNull);
      expect(completionRaw!['bookingId'], equals('BKG-105'));
    });

    test('SenderMockDataSource submits rating raw data', () async {
      const dataSource = SenderMockDataSource();
      final ratingJson = {
        'id': 'RAT-P15',
        'requestId': 'REQ-P15',
        'bookingId': 'BKG-105',
        'travellerName': 'Ravi',
        'rating': 5.0,
        'submittedAt': DateTime.now().toIso8601String(),
        'isSubmitted': false,
      };

      final result = await dataSource.submitRatingRaw(ratingJson);
      expect(result['isSubmitted'], isTrue);
      expect(result['rating'], equals(5.0));
    });

    test('SenderRemoteDataSource throws UnimplementedError for Person 1 endpoints', () {
      const remoteSource = SenderRemoteDataSource();
      expect(() => remoteSource.fetchBookingsRaw(), throwsUnimplementedError);
      expect(() => remoteSource.fetchNotificationsRaw(), throwsUnimplementedError);
      expect(() => remoteSource.fetchTrackingRaw('BKG-101'), throwsUnimplementedError);
    });
  });

  group('Phase 15 SenderResource State Model Tests', () {
    test('SenderResource represents loading, success, empty, and error states', () {
      final loading = SenderResource<String>.loading();
      expect(loading.isLoading, isTrue);

      final success = SenderResource<String>.success('DataLoaded');
      expect(success.isSuccess, isTrue);
      expect(success.data, equals('DataLoaded'));

      final empty = SenderResource<List<dynamic>>.empty();
      expect(empty.isEmpty, isTrue);

      final error = SenderResource<String>.error('Connection Error');
      expect(error.isError, isTrue);
      expect(error.errorMessage, equals('Connection Error'));
    });
  });

  group('Phase 15 Backward Compatibility & UI Safety Tests', () {
    testWidgets('SenderDashboardScreen renders cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: SenderDashboardScreen(),
        ),
      );

      expect(find.text('TRAVGO'), findsOneWidget);
    });

    testWidgets('SenderDeliveryCompletionScreen handles loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SenderDeliveryCompletionScreen(isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
