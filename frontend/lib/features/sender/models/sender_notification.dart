/// Enum representing the types of Sender notifications.
enum SenderNotificationType {
  requestSubmitted,
  travellerAccepted,
  travellerRejected,
  travellerCancelled,
  pickupReminder,
  parcelPickedUp,
  parcelInTransit,
  parcelArrived,
  parcelDelivered,
  deliveryCompleted,
  general,
}

/// Presentation model representing a Sender notification item.
/// 
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final SenderNotificationType type;
  final bool isRead;
  final String? requestId;
  final String? route;
  final String? travellerName;

  const SenderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.requestId,
    this.route,
    this.travellerName,
  });

  SenderNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    SenderNotificationType? type,
    bool? isRead,
    String? requestId,
    String? route,
    String? travellerName,
  }) {
    return SenderNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      requestId: requestId ?? this.requestId,
      route: route ?? this.route,
      travellerName: travellerName ?? this.travellerName,
    );
  }
}
