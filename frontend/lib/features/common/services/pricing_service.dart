import 'dart:math';

import '../../../models/travgo_delivery_booking.dart';

/// Centralized Pricing Engine for TRAVGO Parcel Deliveries.
/// Calculates dynamic estimated delivery prices based on route distance and parcel weight.
class PricingService {
  static const double baseFee = 50.0;
  static const double perKmRate = 1.5;
  static const double perKgRate = 20.0;

  /// Calculates estimated delivery fee in Rupees (₹) from source and destination city names and parcel weight in kg.
  static double calculateEstimatedPrice({
    required String source,
    required String destination,
    required double weightKg,
  }) {
    final srcCoord = TravgoDeliveryBooking.getCityCoordinates(source);
    final dstCoord = TravgoDeliveryBooking.getCityCoordinates(destination);
    final distanceKm = calculateDistanceKm(
      srcCoord.latitude,
      srcCoord.longitude,
      dstCoord.latitude,
      dstCoord.longitude,
    );

    return calculatePriceForDistanceAndWeight(
      distanceKm: distanceKm > 0 ? distanceKm : 100.0,
      weightKg: weightKg,
    );
  }

  /// Calculates price directly from distance in kilometers and parcel weight in kilograms.
  static double calculatePriceForDistanceAndWeight({
    required double distanceKm,
    required double weightKg,
  }) {
    final calculated = baseFee + (distanceKm * perKmRate) + (weightKg * perKgRate);
    return (calculated / 5).round() * 5.0; // Round to nearest 5
  }

  /// Calculates straight-line distance in kilometers using the Haversine formula.
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
