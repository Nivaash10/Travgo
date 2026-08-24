/// Live Tracking Map Screen — Full-Screen OpenStreetMap with Actual Travelled Path
///
/// Full-screen live GPS map displaying Pickup (📦), Current Traveller (🔵),
/// Destination (📍), and Delivered (✓) markers, with solid travelled polyline,
/// remaining route line, accuracy circle, and recenter controls.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../otp/services/otp_service.dart';
import '../../otp/widgets/travgo_theme.dart';
import '../services/location_service.dart';

class LiveTrackingMapScreen extends StatefulWidget {
  const LiveTrackingMapScreen({
    super.key,
    this.initialLocation,
    this.sourceLocation = const LatLng(11.0168, 76.9558),
    this.destinationLocation = const LatLng(13.0827, 80.2707),
    this.pickupLocation,
    this.deliveryLocation,
    this.locationHistory = const [],
    this.sourceName = 'Coimbatore',
    this.destinationName = 'Chennai',
    this.parcelId = 'TRV1024',
  });

  final LatLng? initialLocation;
  final LatLng sourceLocation;
  final LatLng destinationLocation;
  final LatLng? pickupLocation;
  final LatLng? deliveryLocation;
  final List<LatLng> locationHistory;
  final String sourceName;
  final String destinationName;
  final String parcelId;

  @override
  State<LiveTrackingMapScreen> createState() => _LiveTrackingMapScreenState();
}

class _LiveTrackingMapScreenState extends State<LiveTrackingMapScreen> {
  final LocationService _locationService = LocationService();
  final OtpService _otpService = OtpService.instance;
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _deliveryLocation;
  final List<LatLng> _locationHistory = [];

  double? _accuracy;
  DateTime? _lastUpdated;

  bool _isLoadingGps = true;
  String? _gpsStatusMessage;
  bool _isTrackingActive = false;
  bool _isUserPanning = false;

  Timer? _timerTicker;
  String _timeAgoText = 'Just now';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pickupLocation = widget.pickupLocation ?? _otpService.pickupLocation;
    _deliveryLocation = widget.deliveryLocation ?? _otpService.deliveryLocation;
    if (widget.locationHistory.isNotEmpty) {
      _locationHistory.addAll(widget.locationHistory);
    } else if (_otpService.locationHistory.isNotEmpty) {
      _locationHistory.addAll(_otpService.locationHistory);
    }

    _currentLocation = widget.initialLocation;
    if (_otpService.parcelStatus.name != 'delivered') {
      _initGpsStream();
    } else {
      _isLoadingGps = false;
      _isTrackingActive = false;
    }
    _startTimerTicker();
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    _locationService.stopTracking();
    _mapController.dispose();
    super.dispose();
  }

  void _startTimerTicker() {
    _timerTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _lastUpdated == null) return;
      setState(() {
        _timeAgoText = _calculateTimeAgo(_lastUpdated!);
      });
    });
  }

  String _calculateTimeAgo(DateTime updated) {
    final diff = DateTime.now().difference(updated);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds} sec ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    final h = updated.hour.toString().padLeft(2, '0');
    final m = updated.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ─── GPS Stream ───────────────────────────────────────────────────────────

  Future<void> _initGpsStream() async {
    setState(() {
      _isLoadingGps = true;
      _gpsStatusMessage = 'Getting location...';
    });

    try {
      await _locationService.verifyPermissionAndService();

      final initialPos = await _locationService.getCurrentLocation();
      if (mounted) {
        _updateLocationFromPosition(initialPos);
        _mapController.move(_currentLocation!, 15.0);
      }

      await _locationService.startTracking(
        onData: (position) {
          if (!mounted) return;
          _updateLocationFromPosition(position);
          if (!_isUserPanning && _currentLocation != null) {
            _mapController.move(
              _currentLocation!,
              _mapController.camera.zoom,
            );
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isTrackingActive = false;
            _gpsStatusMessage = 'Unable to update location';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isLoadingGps = false;
        _isTrackingActive = false;
        _gpsStatusMessage = msg;
      });
    }
  }

  void _updateLocationFromPosition(Position pos) {
    final pt = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _currentLocation = pt;
      _pickupLocation ??= pt;
      if (_locationHistory.isEmpty || _locationHistory.last != pt) {
        _locationHistory.add(pt);
      }
      _accuracy = pos.accuracy;
      _lastUpdated = DateTime.now();
      _timeAgoText = 'Just now';
      _isLoadingGps = false;
      _isTrackingActive = true;
      _gpsStatusMessage = null;
    });
  }

  void _recenterMap() {
    final target = _currentLocation ?? _pickupLocation ?? widget.sourceLocation;
    setState(() {
      _isUserPanning = false;
    });
    _mapController.move(target, 15.0);
  }

  // ─── Map Data ─────────────────────────────────────────────────────────────

  List<LatLng> get _travelledPathPoints {
    final points = <LatLng>[];

    final start = _pickupLocation ?? widget.sourceLocation;
    points.add(start);

    for (final pt in _locationHistory) {
      if (points.isEmpty || points.last != pt) {
        points.add(pt);
      }
    }

    final current = _deliveryLocation ?? _currentLocation;
    if (current != null) {
      if (points.isEmpty || points.last != current) {
        points.add(current);
      }
    }

    return points;
  }

  List<LatLng> get _remainingRoutePoints {
    final points = <LatLng>[];
    if (_deliveryLocation != null) return points;

    final current = _currentLocation ?? _pickupLocation ?? widget.sourceLocation;
    points.add(current);

    if (points.isEmpty || points.last != widget.destinationLocation) {
      points.add(widget.destinationLocation);
    }

    return points;
  }

  List<Marker> get _markers {
    final markers = <Marker>[];

    // 1. Pickup Marker (Fixed Orange 📦)
    final pickupPt = _pickupLocation ?? widget.sourceLocation;
    markers.add(
      Marker(
        point: pickupPt,
        width: 85,
        height: 54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: TravgoColors.warning),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📦', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 3),
                  Text(
                    _pickupLocation != null ? 'Pickup' : widget.sourceName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: TravgoColors.warning,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.location_on_rounded,
              color: TravgoColors.warning,
              size: 24,
            ),
          ],
        ),
      ),
    );

    // 2. Destination Marker (Fixed Green 📍 — while not delivered)
    if (_deliveryLocation == null) {
      markers.add(
        Marker(
          point: widget.destinationLocation,
          width: 90,
          height: 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TravgoColors.success),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  widget.destinationName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TravgoColors.success,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.location_on_rounded,
                color: TravgoColors.success,
                size: 24,
              ),
            ],
          ),
        ),
      );
    }

    // 3. Delivered Marker (Fixed Green Check ✓ — when delivery OTP verified)
    if (_deliveryLocation != null) {
      markers.add(
        Marker(
          point: _deliveryLocation!,
          width: 90,
          height: 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TravgoColors.success,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: TravgoColors.success.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 3),
                    Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TravgoColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Current Traveller Marker (ONLY ONE active blue 🔵 marker!)
    if (_currentLocation != null && _deliveryLocation == null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 85,
          height: 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TravgoColors.primary,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: TravgoColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  '🔵 Traveller',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TravgoColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: TravgoColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentLocation ?? _pickupLocation ?? widget.sourceLocation;
    final travelled = _travelledPathPoints;
    final remaining = _remainingRoutePoints;

    return Scaffold(
      backgroundColor: TravgoColors.scaffoldBg,
      appBar: travgoAppBar('Live Tracking'),
      body: Stack(
        children: [
          // Full-screen OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialTarget,
              initialZoom: 14.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && !_isUserPanning) {
                  setState(() {
                    _isUserPanning = true;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travgo.app',
              ),

              // Polyline
              PolylineLayer(
                polylines: [
                  if (travelled.length >= 2)
                    Polyline(
                      points: travelled,
                      color: TravgoColors.primary,
                      strokeWidth: 4.5,
                    ),
                  if (remaining.length >= 2)
                    Polyline(
                      points: remaining,
                      color: TravgoColors.primary.withValues(alpha: 0.35),
                      strokeWidth: 3.0,
                    ),
                ],
              ),

              // Accuracy circle around current GPS position
              if (_currentLocation != null && _accuracy != null && _deliveryLocation == null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentLocation!,
                      radius: _accuracy!,
                      useRadiusInMeter: true,
                      color: TravgoColors.primary.withValues(alpha: 0.15),
                      borderColor: TravgoColors.primary,
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),

              // Markers
              MarkerLayer(markers: _markers),

              // OpenStreetMap Attribution
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Recenter FAB
          Positioned(
            right: 16,
            bottom: 210,
            child: FloatingActionButton.small(
              heroTag: 'recenter_fab',
              onPressed: _recenterMap,
              backgroundColor: Colors.white,
              foregroundColor: TravgoColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: TravgoColors.border),
              ),
              child: const Icon(Icons.my_location_rounded, size: 20),
            ),
          ),

          // Bottom Live Coordinates Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildLiveLocationPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveLocationPanel() {
    final isDelivered = _deliveryLocation != null;
    final coordsText = _currentLocation != null
        ? '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
        : _pickupLocation != null
            ? '${_pickupLocation!.latitude.toStringAsFixed(4)}, ${_pickupLocation!.longitude.toStringAsFixed(4)}'
            : 'Acquiring GPS signal...';

    final accuracyText = _accuracy != null
        ? '±${_accuracy!.round()} m'
        : 'Calculating...';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TravgoColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: TravgoColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator row
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isDelivered
                      ? TravgoColors.success
                      : _isTrackingActive
                          ? TravgoColors.primary
                          : _isLoadingGps
                              ? TravgoColors.warning
                              : TravgoColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isDelivered
                    ? 'DELIVERY COMPLETED'
                    : _isTrackingActive
                        ? 'LIVE TRACKING'
                        : _isLoadingGps
                            ? 'GETTING LOCATION...'
                            : 'TRACKING PAUSED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDelivered
                      ? TravgoColors.success
                      : _isTrackingActive
                          ? TravgoColors.primary
                          : _isLoadingGps
                              ? TravgoColors.warning
                              : TravgoColors.error,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                'Parcel #${widget.parcelId}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TravgoColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: TravgoColors.divider, height: 1),
          const SizedBox(height: 14),

          // Coordinates row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TravgoColors.primaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: TravgoColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isDelivered ? 'Delivery Handoff Location' : 'Traveller Coordinates',
                        style: TravgoText.caption),
                    const SizedBox(height: 2),
                    Text(
                      coordsText,
                      style: TravgoText.coordinates,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Details grid: Accuracy & Updated
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  icon: Icons.gps_fixed_rounded,
                  label: 'Accuracy',
                  value: accuracyText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Updated',
                  value: _timeAgoText,
                ),
              ),
            ],
          ),

          if (_gpsStatusMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: TravgoColors.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: TravgoColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _gpsStatusMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TravgoColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TravgoColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TravgoColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TravgoColors.textSecondary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TravgoText.caption),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TravgoColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
