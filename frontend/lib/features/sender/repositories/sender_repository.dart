import '../data/sender_mock_booking_data.dart';
import '../data/sender_mock_delivery_completion_data.dart';
import '../data/sender_mock_delivery_rating.dart';
import '../data/sender_mock_notification_data.dart';
import '../data/sender_mock_tracking_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_completion.dart';
import '../models/sender_delivery_rating.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_notification.dart';
import '../models/sender_search_query.dart';
import '../models/sender_tracking.dart';
import '../models/sender_traveller_match.dart';

/// Abstract repository interface for Sender module operations.
/// 
/// This boundary allows Person 1 to seamlessly swap the [MockSenderRepository]
/// with [RemoteSenderRepository] when backend API contracts are ready.
abstract class SenderRepository {
  Future<List<SenderBooking>> getBookings();
  Future<SenderBooking?> getBookingDetails(String bookingId);
  Future<List<SenderNotification>> getNotifications();
  Future<void> markNotificationAsRead(String notificationId);
  Future<SenderTracking?> getTracking(String bookingId);
  Future<SenderDeliveryCompletion?> getDeliveryCompletion(String bookingId);
  Future<SenderDeliveryRating> submitRating(SenderDeliveryRating rating);
  Future<List<SenderTravellerMatch>> searchTravellers(SenderSearchQuery query);
  Future<SenderDeliveryRequest> createDeliveryRequest(SenderDeliveryRequest request);
}

/// Mock implementation of [SenderRepository] returning isolated mock data.
class MockSenderRepository implements SenderRepository {
  @override
  Future<List<SenderBooking>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return SenderMockBookingData.getMockBookings();
  }

  @override
  Future<SenderBooking?> getBookingDetails(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return SenderMockBookingData.getMockBookings()
        .where((b) => b.id == bookingId)
        .firstOrNull;
  }

  @override
  Future<List<SenderNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return SenderMockNotificationData.getMockNotifications();
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<SenderTracking?> getTracking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return SenderMockTrackingData.getMockTrackings()
        .where((t) => t.bookingId == bookingId || t.requestId == bookingId)
        .firstOrNull;
  }

  @override
  Future<SenderDeliveryCompletion?> getDeliveryCompletion(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return SenderMockDeliveryCompletionData.getCompletionForBooking(bookingId);
  }

  @override
  Future<SenderDeliveryRating> submitRating(SenderDeliveryRating rating) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final submitted = rating.copyWith(isSubmitted: true, submittedAt: DateTime.now());
    SenderMockDeliveryRatingData.saveRating(submitted);
    return submitted;
  }

  @override
  Future<List<SenderTravellerMatch>> searchTravellers(SenderSearchQuery query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      const SenderTravellerMatch(
        travellerName: 'Arun',
        isVerified: true,
        route: 'Coimbatore → Chennai',
        travelDateTime: '25 Aug 2026 • 8:30 AM',
        availableCapacityKg: 5.0,
        priceRupees: 100.0,
        rating: 4.7,
      ),
      const SenderTravellerMatch(
        travellerName: 'Bala',
        isVerified: true,
        route: 'Coimbatore → Chennai',
        travelDateTime: '25 Aug 2026 • 2:00 PM',
        availableCapacityKg: 8.0,
        priceRupees: 150.0,
        rating: 4.9,
      ),
    ];
  }

  @override
  Future<SenderDeliveryRequest> createDeliveryRequest(SenderDeliveryRequest request) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return request;
  }
}

/// Remote implementation of [SenderRepository] ready for Person 1 API integration.
/// 
/// TODO: Replace with official Person 1 API endpoints and HTTP client.
class RemoteSenderRepository implements SenderRepository {
  RemoteSenderRepository();

  @override
  Future<List<SenderBooking>> getBookings() async {
    // TODO: Person 1 will implement: GET /api/v1/sender/bookings
    throw UnimplementedError('GET /api/v1/sender/bookings API contract will be provided by Person 1.');
  }

  @override
  Future<SenderBooking?> getBookingDetails(String bookingId) async {
    // TODO: Person 1 will implement: GET /api/v1/sender/bookings/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/bookings/$bookingId API contract will be provided by Person 1.');
  }

  @override
  Future<List<SenderNotification>> getNotifications() async {
    // TODO: Person 1 will implement: GET /api/v1/sender/notifications
    throw UnimplementedError('GET /api/v1/sender/notifications API contract will be provided by Person 1.');
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // TODO: Person 1 will implement: PATCH /api/v1/sender/notifications/{notificationId}/read
    throw UnimplementedError('PATCH /api/v1/sender/notifications/$notificationId/read API contract will be provided by Person 1.');
  }

  @override
  Future<SenderTracking?> getTracking(String bookingId) async {
    // TODO: Person 1 will implement: GET /api/v1/sender/tracking/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/tracking/$bookingId API contract will be provided by Person 1.');
  }

  @override
  Future<SenderDeliveryCompletion?> getDeliveryCompletion(String bookingId) async {
    // TODO: Person 1 will implement: GET /api/v1/sender/completions/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/completions/$bookingId API contract will be provided by Person 1.');
  }

  @override
  Future<SenderDeliveryRating> submitRating(SenderDeliveryRating rating) async {
    // TODO: Person 1 will implement: POST /api/v1/sender/ratings
    throw UnimplementedError('POST /api/v1/sender/ratings API contract will be provided by Person 1.');
  }

  @override
  Future<List<SenderTravellerMatch>> searchTravellers(SenderSearchQuery query) async {
    // TODO: Person 1 will implement: POST /api/v1/sender/search
    throw UnimplementedError('POST /api/v1/sender/search API contract will be provided by Person 1.');
  }

  @override
  Future<SenderDeliveryRequest> createDeliveryRequest(SenderDeliveryRequest request) async {
    // TODO: Person 1 will implement: POST /api/v1/sender/requests
    throw UnimplementedError('POST /api/v1/sender/requests API contract will be provided by Person 1.');
  }
}
