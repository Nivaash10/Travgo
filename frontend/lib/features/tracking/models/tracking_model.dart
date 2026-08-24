enum ParcelStatus {
  paymentConfirmed,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
  failed,
  disputed,
}

class TrackingModel {
  final String parcelId;
  final String source;
  final String destination;
  final double? latitude;
  final double? longitude;
  final ParcelStatus status;
  final DateTime? lastUpdated;

  const TrackingModel({
    required this.parcelId,
    required this.source,
    required this.destination,
    this.latitude,
    this.longitude,
    required this.status,
    this.lastUpdated,
  });

  TrackingModel copyWith({
    String? parcelId,
    String? source,
    String? destination,
    double? latitude,
    double? longitude,
    ParcelStatus? status,
    DateTime? lastUpdated,
  }) {
    return TrackingModel(
      parcelId: parcelId ?? this.parcelId,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
