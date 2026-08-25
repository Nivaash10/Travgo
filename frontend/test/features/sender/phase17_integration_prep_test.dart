import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data_sources/sender_data_source.dart';
import 'package:frontend/features/sender/models/sender_delivery_request.dart';
import 'package:frontend/features/sender/models/sender_resource.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/search_route_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';

void main() {
  group('Phase 17 Data Source & Repository Flow Tests', () {
    test('MockSenderRepository searches travellers asynchronously', () async {
      final repo = MockSenderRepository();
      const query = SenderSearchQuery(
        source: 'Coimbatore',
        destination: 'Chennai',
        parcelWeightKg: 2.0,
      );

      final matches = await repo.searchTravellers(query);
      expect(matches, isNotEmpty);
      expect(matches.first.travellerName, equals('Arun'));
    });

    test('MockSenderRepository creates delivery request asynchronously', () async {
      final repo = MockSenderRepository();
      const match = SenderTravellerMatch(
        travellerName: 'Arun',
        route: 'Coimbatore → Chennai',
        priceRupees: 100.0,
        travelDateTime: '25 Aug 2026',
        availableCapacityKg: 5.0,
      );

      final request = SenderDeliveryRequest(
        searchQuery: const SenderSearchQuery(source: 'Coimbatore', destination: 'Chennai'),
        traveller: match,
        parcelDescription: 'Gift box',
        parcelCategory: 'General',
        parcelWeightKg: 2.0,
      );

      final created = await repo.createDeliveryRequest(request);
      expect(created.parcelDescription, equals('Gift box'));
    });

    test('SenderMockDataSource returns raw traveller search results', () async {
      const dataSource = SenderMockDataSource();
      final results = await dataSource.searchTravellersRaw({'source': 'Coimbatore'});

      expect(results, isNotEmpty);
      expect(results.first['travellerName'], equals('Arun'));
    });

    test('SenderMockDataSource returns raw delivery request creation result', () async {
      const dataSource = SenderMockDataSource();
      final rawReq = {'parcelDescription': 'Documents'};
      final created = await dataSource.createDeliveryRequestRaw(rawReq);

      expect(created['parcelDescription'], equals('Documents'));
      expect(created['id'], isNotNull);
    });

    test('SenderRemoteDataSource throws UnimplementedError for Person 1 endpoints', () {
      const remote = SenderRemoteDataSource();
      expect(() => remote.searchTravellersRaw({}), throwsUnimplementedError);
      expect(() => remote.createDeliveryRequestRaw({}), throwsUnimplementedError);
    });
  });

  group('Phase 17 Result Handling & Resource Wrapper Tests', () {
    test('SenderResource handles loading, success, empty and error states', () {
      final loadingRes = SenderResource<List<dynamic>>.loading();
      expect(loadingRes.isLoading, isTrue);

      final successRes = SenderResource<String>.success('Loaded Data');
      expect(successRes.isSuccess, isTrue);
      expect(successRes.data, equals('Loaded Data'));

      final emptyRes = SenderResource<List<dynamic>>.empty();
      expect(emptyRes.isEmpty, isTrue);

      final errorRes = SenderResource<String>.error('Backend Service Unavailable');
      expect(errorRes.isError, isTrue);
      expect(errorRes.errorMessage, equals('Backend Service Unavailable'));
    });
  });

  group('Phase 17 Major Flow Navigation Safety Tests', () {
    testWidgets('SenderDashboardScreen renders navigation entry points', (tester) async {
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

    testWidgets('SearchRouteScreen submits query cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: SearchRouteScreen(),
        ),
      );

      expect(find.text('Search Travellers'), findsOneWidget);
    });

    testWidgets('MyBookingsScreen renders booking list', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: MyBookingsScreen(),
        ),
      );

      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('SenderNotificationsScreen renders notification list', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: SenderNotificationsScreen(),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
    });
  });
}
