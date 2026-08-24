import 'sender_delivery_request.dart';

/// Enum representing the Sender delivery lifecycle statuses.
enum SenderDeliveryStatus {
  pending,
  accepted,
  rejected,
  pickupPending,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
}

/// Presentation model representing the current status and tracking details of a Sender delivery request.
/// 
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderDeliveryStatusItem {
  final String requestId;
  final SenderDeliveryRequest request;
  final SenderDeliveryStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? statusMessage;
  final String? pickupLocation;
  final String? deliveryLocation;
  final double? progress;
  final bool travellerAccepted;
  final bool parcelPickedUp;
  final bool delivered;

  const SenderDeliveryStatusItem({
    required this.requestId,
    required this.request,
    this.status = SenderDeliveryStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.statusMessage,
    this.pickupLocation,
    this.deliveryLocation,
    this.progress,
    this.travellerAccepted = false,
    this.parcelPickedUp = false,
    this.delivered = false,
  });

  SenderDeliveryStatusItem copyWith({
    String? requestId,
    SenderDeliveryRequest? request,
    SenderDeliveryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? statusMessage,
    String? pickupLocation,
    String? deliveryLocation,
    double? progress,
    bool? travellerAccepted,
    bool? parcelPickedUp,
    bool? delivered,
  }) {
    return SenderDeliveryStatusItem(
      requestId: requestId ?? this.requestId,
      request: request ?? this.request,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusMessage: statusMessage ?? this.statusMessage,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      progress: progress ?? this.progress,
      travellerAccepted: travellerAccepted ?? this.travellerAccepted,
      parcelPickedUp: parcelPickedUp ?? this.parcelPickedUp,
      delivered: delivered ?? this.delivered,
    );
  }
}
