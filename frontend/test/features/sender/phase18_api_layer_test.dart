import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/models/sender_delivery_request.dart';
import 'package:frontend/features/sender/models/sender_search_query.dart';
import 'package:frontend/features/sender/models/sender_traveller_match.dart';
import 'package:frontend/features/sender/repositories/sender_repository.dart';
import 'package:frontend/features/sender/repositories/sender_repository_factory.dart';
import 'package:frontend/features/sender/services/sender_service.dart';

void main() {
  group('Phase 18 Repository Factory & Architecture Selection Tests', () {
    tearDown(() {
      SenderRepositoryFactory.setUseRemote(false);
    });

    test('SenderRepositoryFactory defaults to MockSenderRepository', () {
      final repo = SenderRepositoryFactory.createRepository();
      expect(repo, isA<MockSenderRepository>());
      expect(SenderRepositoryFactory.isRemoteActive, isFalse);
    });

    test('SenderRepositoryFactory switches to RemoteSenderRepository when enabled', () {
      SenderRepositoryFactory.setUseRemote(true);
      final repo = SenderRepositoryFactory.createRepository();
      expect(repo, isA<RemoteSenderRepository>());
      expect(SenderRepositoryFactory.isRemoteActive, isTrue);
    });

    test('SenderService uses SenderRepositoryFactory by default', () {
      final service = SenderService();
      expect(service.repository, isA<MockSenderRepository>());
    });
  });

  group('Phase 18 Unimplemented Remote Endpoints Safety Tests', () {
    test('RemoteSenderRepository methods throw UnimplementedError for missing contracts', () async {
      final remoteRepo = RemoteSenderRepository();

      expect(() => remoteRepo.getBookings(), throwsUnimplementedError);
      expect(() => remoteRepo.getBookingDetails('BKG-101'), throwsUnimplementedError);
      expect(() => remoteRepo.getNotifications(), throwsUnimplementedError);
      expect(() => remoteRepo.markNotificationAsRead('NOTIF-1'), throwsUnimplementedError);
      expect(() => remoteRepo.getTracking('BKG-101'), throwsUnimplementedError);
      expect(() => remoteRepo.getDeliveryCompletion('BKG-101'), throwsUnimplementedError);
      expect(
        () => remoteRepo.submitRating(
          SenderDeliveryRating(
            id: 'RAT-1',
            requestId: 'REQ-1',
            bookingId: 'BKG-1',
            travellerName: 'Arun',
            submittedAt: DateTime.now(),
          ),
        ),
        throwsUnimplementedError,
      );
      expect(
        () => remoteRepo.searchTravellers(
          const SenderSearchQuery(source: 'Coimbatore', destination: 'Chennai'),
        ),
        throwsUnimplementedError,
      );
      expect(
        () => remoteRepo.createDeliveryRequest(
          const SenderDeliveryRequest(
            searchQuery: SenderSearchQuery(source: 'Coimbatore', destination: 'Chennai'),
            traveller: SenderTravellerMatch(
              travellerName: 'Arun',
              route: 'Coimbatore → Chennai',
              priceRupees: 100.0,
              travelDateTime: '25 Aug 2026',
              availableCapacityKg: 5.0,
            ),
            parcelDescription: 'Box',
            parcelCategory: 'General',
            parcelWeightKg: 2.0,
          ),
        ),
        throwsUnimplementedError,
      );
    });
  });
}
