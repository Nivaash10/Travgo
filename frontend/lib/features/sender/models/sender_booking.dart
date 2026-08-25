import 'sender_delivery_request.dart';
import 'sender_delivery_status.dart';

/// Presentation model representing a Sender booking / delivery request item.
///
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderBooking {
  final String id;
  final SenderDeliveryRequest request;
  final SenderDeliveryStatus status;
  final DateTime createdAt;
  final DateTime? scheduledPickupDate;
  final String? pickupLocation;
  final String? deliveryLocation;
  final String? travellerName;
  final double deliveryPrice;
  final bool canCancel;
  final bool canViewStatus;

  const SenderBooking({
    required this.id,
    required this.request,
    required this.status,
    required this.createdAt,
    this.scheduledPickupDate,
    this.pickupLocation,
    this.deliveryLocation,
    this.travellerName,
    required this.deliveryPrice,
    this.canCancel = true,
    this.canViewStatus = true,
  });

  SenderBooking copyWith({
    String? id,
    SenderDeliveryRequest? request,
    SenderDeliveryStatus? status,
    DateTime? createdAt,
    DateTime? scheduledPickupDate,
    String? pickupLocation,
    String? deliveryLocation,
    String? travellerName,
    double? deliveryPrice,
    bool? canCancel,
    bool? canViewStatus,
  }) {
    return SenderBooking(
      id: id ?? this.id,
      request: request ?? this.request,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledPickupDate: scheduledPickupDate ?? this.scheduledPickupDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      travellerName: travellerName ?? this.travellerName,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      canCancel: canCancel ?? this.canCancel,
      canViewStatus: canViewStatus ?? this.canViewStatus,
    );
  }
}
