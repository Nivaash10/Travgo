import '../data/sender_mock_booking_data.dart';
import '../data/sender_mock_delivery_completion_data.dart';
import '../data/sender_mock_delivery_rating.dart';
import '../data/sender_mock_notification_data.dart';
import '../data/sender_mock_tracking_data.dart';
import '../models/sender_delivery_rating.dart';

/// Abstract Data Source interface for the Sender module.
///
/// Provides a data access boundary between raw payload sources (Mock vs Remote HTTP)
/// and the repository layer.
abstract class SenderDataSource {
  Future<List<Map<String, dynamic>>> fetchBookingsRaw();
  Future<Map<String, dynamic>?> fetchBookingDetailsRaw(String bookingId);
  Future<List<Map<String, dynamic>>> fetchNotificationsRaw();
  Future<Map<String, dynamic>?> fetchTrackingRaw(String bookingId);
  Future<Map<String, dynamic>?> fetchCompletionRaw(String bookingId);
  Future<Map<String, dynamic>> submitRatingRaw(Map<String, dynamic> ratingJson);
  Future<List<Map<String, dynamic>>> searchTravellersRaw(Map<String, dynamic> queryJson);
  Future<Map<String, dynamic>> createDeliveryRequestRaw(Map<String, dynamic> requestJson);
}

/// Mock Data Source implementation using isolated local mock datasets.
class SenderMockDataSource implements SenderDataSource {
  const SenderMockDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchBookingsRaw() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final bookings = SenderMockBookingData.getMockBookings();
    return bookings.map((b) => {
      'id': b.id,
      'status': b.status.name,
      'createdAt': b.createdAt.toIso8601String(),
      'pickupLocation': b.pickupLocation,
      'deliveryLocation': b.deliveryLocation,
      'travellerName': b.travellerName,
      'deliveryPrice': b.deliveryPrice,
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> fetchBookingDetailsRaw(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final booking = SenderMockBookingData.getMockBookings()
        .where((b) => b.id == bookingId)
        .firstOrNull;

    if (booking == null) return null;
    return {
      'id': booking.id,
      'status': booking.status.name,
      'createdAt': booking.createdAt.toIso8601String(),
      'pickupLocation': booking.pickupLocation,
      'deliveryLocation': booking.deliveryLocation,
      'travellerName': booking.travellerName,
      'deliveryPrice': booking.deliveryPrice,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotificationsRaw() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final notifications = SenderMockNotificationData.getMockNotifications();
    return notifications.map((n) => n.toJson()).toList();
  }

  @override
  Future<Map<String, dynamic>?> fetchTrackingRaw(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final tracking = SenderMockTrackingData.getMockTrackings()
        .where((t) => t.bookingId == bookingId || t.requestId == bookingId)
        .firstOrNull;

    if (tracking == null) return null;
    return {
      'bookingId': tracking.bookingId,
      'requestId': tracking.requestId,
      'currentStatus': tracking.currentStatus.name,
      'statusMessage': tracking.statusMessage,
      'source': tracking.source,
      'destination': tracking.destination,
      'travellerName': tracking.travellerName,
      'currentLocation': tracking.currentLocation,
    };
  }

  @override
  Future<Map<String, dynamic>?> fetchCompletionRaw(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final completion = SenderMockDeliveryCompletionData.getCompletionForBooking(bookingId);
    return {
      'bookingId': completion.bookingId,
      'requestId': completion.requestId,
      'deliveredAt': completion.deliveredAt.toIso8601String(),
      'receiverName': completion.receiverName,
      'destination': completion.destination,
      'travellerName': completion.travellerName,
      'parcelDescription': completion.parcelDescription,
      'parcelWeightKg': completion.parcelWeightKg,
      'proofOfDeliveryAvailable': completion.proofOfDeliveryAvailable,
      'proofType': completion.proofType,
      'proofReference': completion.proofReference,
      'deliveryMessage': completion.deliveryMessage,
    };
  }

  @override
  Future<Map<String, dynamic>> submitRatingRaw(Map<String, dynamic> ratingJson) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final rating = SenderDeliveryRating.fromJson(ratingJson);
    final submitted = rating.copyWith(isSubmitted: true, submittedAt: DateTime.now());
    SenderMockDeliveryRatingData.saveRating(submitted);
    return submitted.toJson();
  }

  @override
  Future<List<Map<String, dynamic>>> searchTravellersRaw(Map<String, dynamic> queryJson) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      {
        'travellerName': 'Arun',
        'isVerified': true,
        'route': 'Coimbatore â†’ Chennai',
        'travelDateTime': '25 Aug 2026 â€¢ 8:30 AM',
        'availableCapacityKg': 5.0,
        'priceRupees': 100.0,
        'rating': 4.7,
      },
      {
        'travellerName': 'Bala',
        'isVerified': true,
        'route': 'Coimbatore â†’ Chennai',
        'travelDateTime': '25 Aug 2026 â€¢ 2:00 PM',
        'availableCapacityKg': 8.0,
        'priceRupees': 150.0,
        'rating': 4.9,
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> createDeliveryRequestRaw(Map<String, dynamic> requestJson) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return {
      ...requestJson,
      'id': 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Remote Data Source placeholder ready for Person 1 backend integration.
///
/// TODO: Person 1 will implement real HTTP calls using the shared ApiClient here.
class SenderRemoteDataSource implements SenderDataSource {
  const SenderRemoteDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchBookingsRaw() async {
    // TODO: Person 1 will implement: GET /api/v1/sender/bookings
    throw UnimplementedError('GET /api/v1/sender/bookings will be provided by Person 1.');
  }

  @override
  Future<Map<String, dynamic>?> fetchBookingDetailsRaw(String bookingId) async {
    // TODO: Person 1 will implement: GET /api/v1/sender/bookings/{id}
    throw UnimplementedError('GET /api/v1/sender/bookings/$bookingId will be provided by Person 1.');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotificationsRaw() async {
    // TODO: Person 1 will implement: GET /api/v1/sender/notifications
    throw UnimplementedError('GET /api/v1/sender/notifications will be provided by Person 1.');
  }

  @override
  Future<Map<String, dynamic>?> fetchTrackingRaw(String bookingId) async {
    // TODO: Person 1 will implement: GET /api/v1/sender/tracking/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/tracking/$bookingId will be provided by Person 1.');
  }

  @override
  Future<Map<String, dynamic>?> fetchCompletionRaw(String bookingId) async {
    // TODO: Person 1 will implement: GET /api/v1/sender/completions/{bookingId}
    throw UnimplementedError('GET /api/v1/sender/completions/$bookingId will be provided by Person 1.');
  }

  @override
  Future<Map<String, dynamic>> submitRatingRaw(Map<String, dynamic> ratingJson) async {
    // TODO: Person 1 will implement: POST /api/v1/sender/ratings
    throw UnimplementedError('POST /api/v1/sender/ratings will be provided by Person 1.');
  }

  @override
  Future<List<Map<String, dynamic>>> searchTravellersRaw(Map<String, dynamic> queryJson) async {
    // TODO: Person 1 will implement: POST /api/v1/sender/search
    throw UnimplementedError('POST /api/v1/sender/search will be provided by Person 1.');
  }

  @override
  Future<Map<String, dynamic>> createDeliveryRequestRaw(Map<String, dynamic> requestJson) async {
    // TODO: Person 1 will implement: POST /api/v1/sender/requests
    throw UnimplementedError('POST /api/v1/sender/requests will be provided by Person 1.');
  }
}
