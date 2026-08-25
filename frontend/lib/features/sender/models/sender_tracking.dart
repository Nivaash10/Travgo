/// Enum representing the status of delivery tracking.
enum SenderTrackingStatus {
  pending,
  accepted,
  pickupPending,
  pickedUp,
  inTransit,
  arrived,
  delivered,
  cancelled,
}

/// Represents a single chronological tracking timeline event.
class SenderTrackingEvent {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final SenderTrackingStatus status;
  final bool isCompleted;
  final bool isCurrent;

  const SenderTrackingEvent({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.status,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

/// Frontend presentation model representing live delivery tracking for a Sender.
///
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderTracking {
  final String requestId;
  final String bookingId;
  final SenderTrackingStatus currentStatus;
  final String statusMessage;
  final String source;
  final String destination;
  final String travellerName;
  final bool travellerVerified;
  final String travelDateTime;
  final String? estimatedArrival;
  final String? currentLocation;
  final DateTime lastUpdated;
  final double progressPercentage; // 0.0 to 1.0
  final List<SenderTrackingEvent> events;

  const SenderTracking({
    required this.requestId,
    required this.bookingId,
    required this.currentStatus,
    required this.statusMessage,
    required this.source,
    required this.destination,
    required this.travellerName,
    this.travellerVerified = true,
    required this.travelDateTime,
    this.estimatedArrival,
    this.currentLocation,
    required this.lastUpdated,
    this.progressPercentage = 0.0,
    this.events = const [],
  });

  SenderTracking copyWith({
    String? requestId,
    String? bookingId,
    SenderTrackingStatus? currentStatus,
    String? statusMessage,
    String? source,
    String? destination,
    String? travellerName,
    bool? travellerVerified,
    String? travelDateTime,
    String? estimatedArrival,
    String? currentLocation,
    DateTime? lastUpdated,
    double? progressPercentage,
    List<SenderTrackingEvent>? events,
  }) {
    return SenderTracking(
      requestId: requestId ?? this.requestId,
      bookingId: bookingId ?? this.bookingId,
      currentStatus: currentStatus ?? this.currentStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      travellerName: travellerName ?? this.travellerName,
      travellerVerified: travellerVerified ?? this.travellerVerified,
      travelDateTime: travelDateTime ?? this.travelDateTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      currentLocation: currentLocation ?? this.currentLocation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      events: events ?? this.events,
    );
  }
}
