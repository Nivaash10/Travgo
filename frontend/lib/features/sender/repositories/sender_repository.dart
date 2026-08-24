import '../data/sender_mock_booking_data.dart';
import '../data/sender_mock_delivery_completion_data.dart';
import '../data/sender_mock_delivery_rating.dart';
import '../data/sender_mock_notification_data.dart';
import '../data/sender_mock_tracking_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_completion.dart';
import '../models/sender_delivery_rating.dart';
import '../models/sender_notification.dart';
import '../models/sender_tracking.dart';

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
}

/// Remote implementation of [SenderRepository] ready for Person 1 API integration.
/// 
/// TODO: Replace with official Person 1 API endpoints and HTTP client.
class RemoteSenderRepository implements SenderRepository {
  // TODO: Inject Person 1 shared ApiClient when available
  RemoteSenderRepository();

  @override
  Future<List<SenderBooking>> getBookings() async {
    // TODO: Replace with official Person 1 API endpoint: GET /api/v1/sender/bookings
    throw UnimplementedError('GET /api/v1/sender/bookings API contract will be provided by Person 1.');
  }

  @override
  Future<SenderBooking?> getBookingDetails(String bookingId) async {
    // TODO: Replace with official Person 1 API endpoint: GET /api/v1/sender/bookings/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/bookings/$bookingId API contract will be provided by Person 1.');
  }

  @override
  Future<List<SenderNotification>> getNotifications() async {
    // TODO: Replace with official Person 1 API endpoint: GET /api/v1/sender/notifications
    throw UnimplementedError('GET /api/v1/sender/notifications API contract will be provided by Person 1.');
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // TODO: Replace with official Person 1 API endpoint: PATCH /api/v1/sender/notifications/{notificationId}/read
    throw UnimplementedError('PATCH /api/v1/sender/notifications/$notificationId/read API contract will be provided by Person 1.');
  }

  @override
  Future<SenderTracking?> getTracking(String bookingId) async {
    // TODO: Replace with official Person 1 API endpoint: GET /api/v1/sender/tracking/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/tracking/$bookingId API contract will be provided by Person 1.');
  }

  @override
  Future<SenderDeliveryCompletion?> getDeliveryCompletion(String bookingId) async {
    // TODO: Replace with official Person 1 API endpoint: GET /api/v1/sender/completions/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/completions/$bookingId API contract will be provided by Person 1.');
  }

  @override
  Future<SenderDeliveryRating> submitRating(SenderDeliveryRating rating) async {
    // TODO: Replace with official Person 1 API endpoint: POST /api/v1/sender/ratings
    throw UnimplementedError('POST /api/v1/sender/ratings API contract will be provided by Person 1.');
  }
}
