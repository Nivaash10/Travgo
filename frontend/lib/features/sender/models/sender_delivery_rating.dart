/// Frontend presentation model representing a Sender's rating & feedback for a completed delivery.
/// 
/// Note: This is a presentation model. Official API/backend mapping will be provided by Person 1.
class SenderDeliveryRating {
  final String id;
  final String requestId;
  final String bookingId;
  final String travellerName;
  final String? route;
  final double rating;
  final String? feedback;
  final DateTime submittedAt;
  final bool isSubmitted;

  const SenderDeliveryRating({
    required this.id,
    required this.requestId,
    required this.bookingId,
    required this.travellerName,
    this.route,
    this.rating = 0.0,
    this.feedback,
    required this.submittedAt,
    this.isSubmitted = false,
  });

  /// Check if the rating value is valid (between 1.0 and 5.0)
  bool get isValidRating => rating >= 1.0 && rating <= 5.0;

  SenderDeliveryRating copyWith({
    String? id,
    String? requestId,
    String? bookingId,
    String? travellerName,
    String? route,
    double? rating,
    String? feedback,
    DateTime? submittedAt,
    bool? isSubmitted,
  }) {
    return SenderDeliveryRating(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      bookingId: bookingId ?? this.bookingId,
      travellerName: travellerName ?? this.travellerName,
      route: route ?? this.route,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      submittedAt: submittedAt ?? this.submittedAt,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'bookingId': bookingId,
      'travellerName': travellerName,
      'route': route,
      'rating': rating,
      'feedback': feedback,
      'submittedAt': submittedAt.toIso8601String(),
      'isSubmitted': isSubmitted,
    };
  }

  factory SenderDeliveryRating.fromJson(Map<String, dynamic> json) {
    return SenderDeliveryRating(
      id: json['id'] as String? ?? '',
      requestId: json['requestId'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      travellerName: json['travellerName'] as String? ?? '',
      route: json['route'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isSubmitted: json['isSubmitted'] as bool? ?? false,
    );
  }
}
