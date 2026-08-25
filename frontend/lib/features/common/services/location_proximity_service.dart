import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Proximity Service for calculating location distances and formatting proximity strings.
class LocationProximityService {
  /// Calculates straight-line distance in kilometers between two GPS coordinates using Haversine formula.
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// Formats human-readable proximity string (e.g. "2.4 km from pickup" or "Location unavailable").
  static String getFormattedProximity(LatLng? travellerLocation, LatLng pickupLocation) {
    if (travellerLocation == null) {
      return 'Location unavailable';
    }
    final dist = calculateDistanceKm(
      travellerLocation.latitude,
      travellerLocation.longitude,
      pickupLocation.latitude,
      pickupLocation.longitude,
    );
    if (dist < 0.1) {
      return 'At pickup location';
    }
    return '${dist.toStringAsFixed(1)} km from pickup';
  }
}
