/// Location Service — Phase 2 Step 3
///
/// Responsible for device GPS location access, permissions, and position updates.
/// Uses the `geolocator` package for mobile location tracking.
library;

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;

  /// Checks whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks current location permission status.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission from the user.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Verifies location service availability and permission status.
  /// Throws an [Exception] with user-understandable description on failure.
  Future<bool> verifyPermissionAndService() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Location services are disabled. Please enable GPS in device settings.');
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Please enable location access in app settings.');
    }

    return true;
  }

  /// Gets the single-shot current device location.
  Future<Position> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    await verifyPermissionAndService();
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
      ),
    );
  }

  /// Obtains a live stream of position updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Starts listening to position updates and delegates received positions to [onData].
  Future<void> startTracking({
    required Function(Position position) onData,
    Function(dynamic error)? onError,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) async {
    await verifyPermissionAndService();
    await stopTracking();

    final stream = getPositionStream(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionSubscription = stream.listen(
      onData,
      onError: onError,
      cancelOnError: false,
    );
  }

  /// Stops tracking and cancels active position stream listener.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Returns true if active tracking subscription is running.
  bool get isTracking => _positionSubscription != null;
}
