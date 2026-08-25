import 'sender_delivery_status.dart';

/// Frontend presentation model representing a completed delivery with proof-of-delivery data.
///
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderDeliveryCompletion {
  final String bookingId;
  final String requestId;
  final SenderDeliveryStatus deliveryStatus;
  final DateTime deliveredAt;
  final String? receiverName;
  final String destination;
  final String travellerName;
  final bool travellerVerified;
  final double? travellerRating;
  final String parcelDescription;
  final String parcelCategory;
  final double parcelWeightKg;
  final bool proofOfDeliveryAvailable;
  final String? proofType;
  final String? proofReference;
  final String deliveryMessage;

  const SenderDeliveryCompletion({
    required this.bookingId,
    required this.requestId,
    this.deliveryStatus = SenderDeliveryStatus.delivered,
    required this.deliveredAt,
    this.receiverName,
    required this.destination,
    required this.travellerName,
    this.travellerVerified = true,
    this.travellerRating = 4.8,
    required this.parcelDescription,
    this.parcelCategory = 'General',
    required this.parcelWeightKg,
    this.proofOfDeliveryAvailable = true,
    this.proofType,
    this.proofReference,
    required this.deliveryMessage,
  });

  SenderDeliveryCompletion copyWith({
    String? bookingId,
    String? requestId,
    SenderDeliveryStatus? deliveryStatus,
    DateTime? deliveredAt,
    String? receiverName,
    String? destination,
    String? travellerName,
    bool? travellerVerified,
    double? travellerRating,
    String? parcelDescription,
    String? parcelCategory,
    double? parcelWeightKg,
    bool? proofOfDeliveryAvailable,
    String? proofType,
    String? proofReference,
    String? deliveryMessage,
  }) {
    return SenderDeliveryCompletion(
      bookingId: bookingId ?? this.bookingId,
      requestId: requestId ?? this.requestId,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      receiverName: receiverName ?? this.receiverName,
      destination: destination ?? this.destination,
      travellerName: travellerName ?? this.travellerName,
      travellerVerified: travellerVerified ?? this.travellerVerified,
      travellerRating: travellerRating ?? this.travellerRating,
      parcelDescription: parcelDescription ?? this.parcelDescription,
      parcelCategory: parcelCategory ?? this.parcelCategory,
      parcelWeightKg: parcelWeightKg ?? this.parcelWeightKg,
      proofOfDeliveryAvailable:
          proofOfDeliveryAvailable ?? this.proofOfDeliveryAvailable,
      proofType: proofType ?? this.proofType,
      proofReference: proofReference ?? this.proofReference,
      deliveryMessage: deliveryMessage ?? this.deliveryMessage,
    );
  }
}
