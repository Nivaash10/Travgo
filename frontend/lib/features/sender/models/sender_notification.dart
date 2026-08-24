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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'requestId': requestId,
      'route': route,
      'travellerName': travellerName,
    };
  }

  factory SenderNotification.fromJson(Map<String, dynamic> json) {
    return SenderNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: SenderNotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SenderNotificationType.general,
      ),
      isRead: json['isRead'] as bool? ?? false,
      requestId: json['requestId'] as String?,
      route: json['route'] as String?,
      travellerName: json['travellerName'] as String?,
    );
  }
}
