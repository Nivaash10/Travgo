import 'package:latlong2/latlong.dart';

enum ParcelStatus {
  paymentConfirmed,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
  failed,
  disputed,
}

/// ParcelTrip — Real trip & parcel data model for dynamic tracking
class ParcelTrip {
  final String parcelId;
  final String tripId;
  final String sourceName;
  final LatLng sourceLocation;
  final String destinationName;
  final LatLng destinationLocation;
  final String travellerName;
  final ParcelStatus status;

  const ParcelTrip({
    required this.parcelId,
    required this.tripId,
    required this.sourceName,
    required this.sourceLocation,
    required this.destinationName,
    required this.destinationLocation,
    this.travellerName = 'Traveller',
    this.status = ParcelStatus.pickedUp,
  });

  /// Factory constructor to parse JSON from backend API or Firestore document
  factory ParcelTrip.fromJson(Map<String, dynamic> json) {
    return ParcelTrip(
      parcelId: json['parcelId'] as String? ?? 'TRV1024',
      tripId: json['tripId'] as String? ?? 'TRIP001',
      sourceName: json['sourceName'] as String? ?? 'Source',
      sourceLocation: LatLng(
        (json['sourceLatitude'] as num?)?.toDouble() ?? 11.0168,
        (json['sourceLongitude'] as num?)?.toDouble() ?? 76.9558,
      ),
      destinationName: json['destinationName'] as String? ?? 'Destination',
      destinationLocation: LatLng(
        (json['destinationLatitude'] as num?)?.toDouble() ?? 13.0827,
        (json['destinationLongitude'] as num?)?.toDouble() ?? 80.2707,
      ),
      travellerName: json['travellerName'] as String? ?? 'Traveller',
      status: ParcelStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParcelStatus.pickedUp,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parcelId': parcelId,
      'tripId': tripId,
      'sourceName': sourceName,
      'sourceLatitude': sourceLocation.latitude,
      'sourceLongitude': sourceLocation.longitude,
      'destinationName': destinationName,
      'destinationLatitude': destinationLocation.latitude,
      'destinationLongitude': destinationLocation.longitude,
      'travellerName': travellerName,
      'status': status.name,
    };
  }
}

class TrackingModel {
  final String parcelId;
  final String source;
  final String destination;
  final double? latitude;
  final double? longitude;
  final LatLng? pickupLocation;
  final LatLng? deliveryLocation;
  final List<LatLng> locationHistory;
  final ParcelStatus status;
  final DateTime? lastUpdated;

  const TrackingModel({
    required this.parcelId,
    required this.source,
    required this.destination,
    this.latitude,
    this.longitude,
    this.pickupLocation,
    this.deliveryLocation,
    this.locationHistory = const [],
    required this.status,
    this.lastUpdated,
  });

  TrackingModel copyWith({
    String? parcelId,
    String? source,
    String? destination,
    double? latitude,
    double? longitude,
    LatLng? pickupLocation,
    LatLng? deliveryLocation,
    List<LatLng>? locationHistory,
    ParcelStatus? status,
    DateTime? lastUpdated,
  }) {
    return TrackingModel(
      parcelId: parcelId ?? this.parcelId,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      locationHistory: locationHistory ?? this.locationHistory,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
