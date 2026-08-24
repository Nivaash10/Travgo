import '../models/sender_delivery_rating.dart';

/// Isolated frontend-only mock dataset for Sender delivery ratings.
class SenderMockDeliveryRatingData {
  static final List<SenderDeliveryRating> _mockRatings = [
    // 1. Completed delivery with rating already submitted
    SenderDeliveryRating(
      id: 'RAT-102',
      requestId: 'REQ-102',
      bookingId: 'BKG-102',
      travellerName: 'Bala',
      route: 'Coimbatore → Bangalore',
      rating: 5.0,
      feedback: 'Excellent service! Handled the parcel with care and communicated well.',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      isSubmitted: true,
    ),

    // 2. Completed delivery awaiting rating
    SenderDeliveryRating(
      id: 'RAT-105',
      requestId: 'REQ-105',
      bookingId: 'BKG-105',
      travellerName: 'Ravi',
      route: 'Coimbatore → Chennai',
      rating: 0.0,
      feedback: null,
      submittedAt: DateTime.now(),
      isSubmitted: false,
    ),
  ];

  static List<SenderDeliveryRating> getMockRatings() => List.unmodifiable(_mockRatings);

  static SenderDeliveryRating getRatingForBooking(String bookingId, {String? travellerName, String? route}) {
    final match = _mockRatings.where((r) => r.bookingId == bookingId || r.requestId == bookingId).firstOrNull;
    if (match != null) return match;

    return SenderDeliveryRating(
      id: 'RAT-$bookingId',
      requestId: 'REQ-$bookingId',
      bookingId: bookingId,
      travellerName: travellerName ?? 'Arun',
      route: route ?? 'Coimbatore → Chennai',
      rating: 0.0,
      feedback: null,
      submittedAt: DateTime.now(),
      isSubmitted: false,
    );
  }

  static void saveRating(SenderDeliveryRating rating) {
    final index = _mockRatings.indexWhere((r) => r.bookingId == rating.bookingId || r.id == rating.id);
    if (index != -1) {
      _mockRatings[index] = rating;
    } else {
      _mockRatings.add(rating);
    }
  }
}
