/// Routing Service — OSRM Open Source Routing Engine & Dynamic Road Alignment
///
/// Fetches actual road-following route geometry between ANY dynamic start and destination coordinates.
/// Uses OSRM public driving API (GeoJSON format with `alternatives=true`). 100% free, zero Google Maps API keys.
/// Includes high-performance local road-snapping (snapPointToRoute) for GPS path alignment.
library;

import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<List<LatLng>> alternativeRoutes;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.alternativeRoutes = const [],
  });
}

class RoutingService {
  static final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  /// Fetches actual road-following geometry and alternatives from OSRM public API.
  /// Start & Destination points format: [longitude, latitude] in OSRM URL.
  Future<RouteResult?> getRoute({
    required LatLng start,
    required LatLng destination,
  }) async {
    // Coordinate validation
    if (start.latitude < -90.0 || start.latitude > 90.0 ||
        start.longitude < -180.0 || start.longitude > 180.0 ||
        destination.latitude < -90.0 || destination.latitude > 90.0 ||
        destination.longitude < -180.0 || destination.longitude > 180.0) {
      return null;
    }

    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson&alternatives=true';

    try {
      final request = await _httpClient.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final bodyText = await response.transform(utf8.decoder).join();
        final jsonMap = jsonDecode(bodyText) as Map<String, dynamic>;

        if (jsonMap['code'] == 'Ok' &&
            jsonMap['routes'] is List &&
            (jsonMap['routes'] as List).isNotEmpty) {
          final routesList = jsonMap['routes'] as List<dynamic>;

          // 1. Primary / Fastest Route (routes[0])
          final firstRoute = routesList[0] as Map<String, dynamic>;
          final geometry = firstRoute['geometry'] as Map<String, dynamic>;
          final coords = geometry['coordinates'] as List<dynamic>;

          final primaryPoints = <LatLng>[];
          for (final c in coords) {
            if (c is List && c.length >= 2) {
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              primaryPoints.add(LatLng(lat, lon));
            }
          }

          final dist = (firstRoute['distance'] as num?)?.toDouble() ?? 0.0;
          final dur = (firstRoute['duration'] as num?)?.toDouble() ?? 0.0;

          // 2. Parse Alternative Routes (routes[1], routes[2], ...)
          final alternatives = <List<LatLng>>[];
          for (int i = 1; i < routesList.length; i++) {
            final altRoute = routesList[i] as Map<String, dynamic>;
            final altGeometry = altRoute['geometry'] as Map<String, dynamic>;
            final altCoords = altGeometry['coordinates'] as List<dynamic>;

            final altPoints = <LatLng>[];
            for (final c in altCoords) {
              if (c is List && c.length >= 2) {
                final lon = (c[0] as num).toDouble();
                final lat = (c[1] as num).toDouble();
                altPoints.add(LatLng(lat, lon));
              }
            }
            if (altPoints.isNotEmpty) {
              alternatives.add(altPoints);
            }
          }

          return RouteResult(
            points: primaryPoints,
            distanceMeters: dist,
            durationSeconds: dur,
            alternativeRoutes: alternatives,
          );
        }
      }
    } catch (_) {
      // Graceful fallback for network offline/timeout without crashing
    }
    return null;
  }

  /// Snaps a raw GPS point onto the nearest segment of the planned road route
  /// if within [maxSnapDistanceMeters] (default 50m). Otherwise returns raw point.
  static LatLng snapPointToRoute(
    LatLng point,
    List<LatLng> routePoints, {
    double maxSnapDistanceMeters = 50.0,
  }) {
    if (routePoints.length < 2) return point;

    LatLng bestSnappedPoint = point;
    double minDistanceMeters = double.infinity;

    for (int i = 0; i < routePoints.length - 1; i++) {
      final a = routePoints[i];
      final b = routePoints[i + 1];

      final abLat = b.latitude - a.latitude;
      final abLng = b.longitude - a.longitude;
      final abSquare = abLat * abLat + abLng * abLng;

      if (abSquare == 0) continue;

      final apLat = point.latitude - a.latitude;
      final apLng = point.longitude - a.longitude;
      final t = ((apLat * abLat + apLng * abLng) / abSquare).clamp(0.0, 1.0);

      final projLat = a.latitude + t * abLat;
      final projLng = a.longitude + t * abLng;

      final dist = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        projLat,
        projLng,
      );

      if (dist < minDistanceMeters) {
        minDistanceMeters = dist;
        bestSnappedPoint = LatLng(projLat, projLng);
      }
    }

    if (minDistanceMeters <= maxSnapDistanceMeters) {
      return bestSnappedPoint;
    }
    return point;
  }
}
