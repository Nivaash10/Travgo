/// Placeholder service for Person 1's backend HTTP API endpoints.
///
/// Official API URLs, headers, and request/response DTO transformers
/// will be integrated when Person 1 supplies the backend mapping.
class SenderApiService {
  final String baseUrl;

  const SenderApiService({
    this.baseUrl = 'https://api.travgo.com/v1/sender',
  });

  /// GET /sender/bookings
  /// TODO: Replace with official Person 1 API endpoint.
  Future<Map<String, dynamic>> fetchBookingsJson() async {
    throw UnimplementedError('GET $baseUrl/bookings will be provided by Person 1.');
  }

  /// GET /sender/bookings/{id}
  /// TODO: Replace with official Person 1 API endpoint.
  Future<Map<String, dynamic>> fetchBookingDetailJson(String bookingId) async {
    throw UnimplementedError('GET $baseUrl/bookings/$bookingId will be provided by Person 1.');
  }

  /// POST /sender/requests
  /// TODO: Replace with official Person 1 API endpoint.
  Future<Map<String, dynamic>> postDeliveryRequestJson(Map<String, dynamic> requestJson) async {
    throw UnimplementedError('POST $baseUrl/requests will be provided by Person 1.');
  }

  /// GET /sender/notifications
  /// TODO: Replace with official Person 1 API endpoint.
  Future<List<dynamic>> fetchNotificationsJson() async {
    throw UnimplementedError('GET $baseUrl/notifications will be provided by Person 1.');
  }

  /// GET /sender/tracking/{bookingId}
  /// TODO: Replace with official Person 1 API endpoint.
  Future<Map<String, dynamic>> fetchTrackingJson(String bookingId) async {
    throw UnimplementedError('GET $baseUrl/tracking/$bookingId will be provided by Person 1.');
  }

  /// GET /sender/completion/{bookingId}
  /// TODO: Replace with official Person 1 API endpoint.
  Future<Map<String, dynamic>> fetchCompletionJson(String bookingId) async {
    throw UnimplementedError('GET $baseUrl/completion/$bookingId will be provided by Person 1.');
  }

  /// POST /sender/ratings
  /// TODO: Replace with official Person 1 API endpoint.
  Future<Map<String, dynamic>> postRatingJson(Map<String, dynamic> ratingJson) async {
    throw UnimplementedError('POST $baseUrl/ratings will be provided by Person 1.');
  }
}
