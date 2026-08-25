/// Professional Satellite Live Tracking Screen — Fully Responsive Navigation UI
///
/// Hero Satellite map UI using `flutter_map` + Esri World Imagery & OSRM Road Routing.
/// Adapts seamlessly across Small Phones (<360px), Medium/Large Phones, Tablets (Portrait & Landscape), and Desktop/Web.
/// Features dual layout engines (Vertical Overlay for Portrait, Side-by-Side Dual Pane for Landscape/Tablet/Desktop),
/// OSRM road-following route calculation (with primary & alternative routes),
/// real device GPS updates with accuracy filtering (<=35m) and local road-snapping,
/// route deviation detection, and Delivery OTP handover.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../otp/screens/delivery_otp_screen.dart';
import '../../otp/services/otp_service.dart' hide ParcelStatus;
import '../../otp/widgets/travgo_theme.dart';
import '../models/tracking_model.dart';
import '../../../models/travgo_delivery_booking.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import '../widgets/tracking_map.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({
    super.key,
    this.trip,
    this.parcelId = 'TRV1024',
    this.sourceName = 'Coimbatore',
    this.sourceLocation = const LatLng(11.0168, 76.9558),
    this.destinationName = 'Chennai',
    this.destinationLocation = const LatLng(13.0827, 80.2707),
  });

  final ParcelTrip? trip;
  final String parcelId;
  final String sourceName;
  final LatLng sourceLocation;
  final String destinationName;
  final LatLng destinationLocation;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final LocationService _locationService = LocationService();
  final OtpService _otpService = OtpService.instance;
  final RoutingService _routingService = RoutingService();

  late String _parcelId;
  late LatLng _sourceLocation;
  late LatLng _destinationLocation;
  late String _sourceName;
  late String _destinationName;

  LatLng? _pickupLocation;
  LatLng? _currentLocation;
  LatLng? _deliveryLocation;

  /// Source of truth: raw unaltered GPS coordinates from device
  final List<LatLng> _rawGpsHistory = [];

  /// Road-snapped GPS coordinates displayed on the map
  final List<LatLng> _locationHistory = [];
  List<LatLng> _plannedRoute = [];
  List<List<LatLng>> _alternativeRoutes = [];

  String? _roadDistanceText;
  String? _roadDurationText;
  String? _routingError;

  ParcelStatus _status = ParcelStatus.pickedUp;
  DateTime? _lastUpdated;

  bool _isRefreshing = false;
  bool _isRouteLoading = false;
  bool _isOffRoute = false;
  bool _isFollowingTraveller = true;
  bool _simulateDestinationArrival = false;
  Timer? _timerTicker;
  String _timeAgoText = 'Just now';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initTripParameters();
    _syncStatusFromOtp();
    _fetchPlannedRoute();
    _startGpsTracking();
    _startTimerTicker();
  }

  @override
  void didUpdateWidget(covariant TrackingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip ||
        oldWidget.sourceLocation != widget.sourceLocation ||
        oldWidget.destinationLocation != widget.destinationLocation ||
        oldWidget.sourceName != widget.sourceName ||
        oldWidget.destinationName != widget.destinationName) {
      _initTripParameters();
      _plannedRoute.clear();
      _alternativeRoutes.clear();
      _fetchPlannedRoute();
    }
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    _locationService.stopTracking();
    super.dispose();
  }

  void _initTripParameters() {
    if (widget.trip != null) {
      _parcelId = widget.trip!.parcelId;
      _sourceName = widget.trip!.sourceName;
      _sourceLocation = widget.trip!.sourceLocation;
      _destinationName = widget.trip!.destinationName;
      _destinationLocation = widget.trip!.destinationLocation;
    } else {
      _parcelId = widget.parcelId;
      _sourceName = widget.sourceName;
      _sourceLocation = (widget.sourceLocation == const LatLng(11.0168, 76.9558) && widget.sourceName != 'Coimbatore')
          ? TravgoDeliveryBooking.getCityCoordinates(widget.sourceName)
          : widget.sourceLocation;
      _destinationName = widget.destinationName;
      _destinationLocation = (widget.destinationLocation == const LatLng(13.0827, 80.2707) && widget.destinationName != 'Chennai')
          ? TravgoDeliveryBooking.getCityCoordinates(widget.destinationName)
          : widget.destinationLocation;
    }
  }

  bool _isValidCoordinate(LatLng loc) {
    return loc.latitude >= -90.0 &&
        loc.latitude <= 90.0 &&
        loc.longitude >= -180.0 &&
        loc.longitude <= 180.0;
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
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    final h = updated.hour.toString().padLeft(2, '0');
    final m = updated.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _syncStatusFromOtp() {
    _pickupLocation = _otpService.pickupLocation;
    _deliveryLocation = _otpService.deliveryLocation;
    if (_otpService.locationHistory.isNotEmpty) {
      _locationHistory.addAll(_otpService.locationHistory);
      _rawGpsHistory.addAll(_otpService.locationHistory);
    }

    if (_otpService.parcelStatus.name == 'delivered') {
      _status = ParcelStatus.delivered;
    } else if (_otpService.parcelStatus.name == 'pickedUp') {
      _status = ParcelStatus.pickedUp;
    }
  }

  // ─── OSRM Dynamic Road Routing ───────────────────────────────────────────

  Future<void> _fetchPlannedRoute() async {
    if (!_isValidCoordinate(_sourceLocation) || !_isValidCoordinate(_destinationLocation)) {
      setState(() {
        _routingError = 'Location information unavailable';
      });
      return;
    }

    final start = _pickupLocation ?? _sourceLocation;

    setState(() {
      _isRouteLoading = true;
      _routingError = null;
    });

    final result = await _routingService.getRoute(
      start: start,
      destination: _destinationLocation,
    );

    if (mounted) {
      setState(() {
        _isRouteLoading = false;
        if (result != null && result.points.isNotEmpty) {
          _plannedRoute = result.points;
          _alternativeRoutes = result.alternativeRoutes;

          // Road distance formatting
          final km = result.distanceMeters / 1000.0;
          _roadDistanceText = km >= 1.0
              ? 'Approx. ${km.toStringAsFixed(1)} km'
              : 'Approx. ${result.distanceMeters.round()} m';

          // Road duration formatting
          final hours = (result.durationSeconds / 3600).floor();
          final minutes = ((result.durationSeconds % 3600) / 60).round();
          if (hours > 0) {
            _roadDurationText = '$hours hr $minutes min est.';
          } else {
            _roadDurationText = '$minutes min est.';
          }

          // Re-snap existing raw points to newly loaded planned route
          if (_rawGpsHistory.isNotEmpty) {
            _locationHistory.clear();
            for (final pt in _rawGpsHistory) {
              final snapped = RoutingService.snapPointToRoute(pt, _plannedRoute);
              _locationHistory.add(snapped);
            }
            _otpService.locationHistory = _locationHistory;
          }
        } else {
          _routingError = 'Unable to calculate route';
        }
      });
    }
  }

  // ─── Distance & Destination Detection ───────────────────────────────────

  /// Distance in meters between current GPS location and destination
  double? get _distanceToDestinationMeters {
    final target = _currentLocation ?? _pickupLocation;
    if (target == null) return null;
    return Geolocator.distanceBetween(
      target.latitude,
      target.longitude,
      _destinationLocation.latitude,
      _destinationLocation.longitude,
    );
  }

  /// True if traveller is within 100 meters threshold or arrival is simulated for demo
  bool get _hasReachedDestination {
    if (_status == ParcelStatus.delivered || _deliveryLocation != null) return true;
    if (_simulateDestinationArrival) return true;
    final dist = _distanceToDestinationMeters;
    return dist != null && dist <= 100.0;
  }

  // ─── GPS Operations ──────────────────────────────────────────────────────

  Future<void> _startGpsTracking() async {
    if (_status == ParcelStatus.delivered) return;

    try {
      await _locationService.verifyPermissionAndService();

      final initialPos = await _locationService.getCurrentLocation();
      if (mounted) {
        final posPt = LatLng(initialPos.latitude, initialPos.longitude);
        setState(() {
          _currentLocation = posPt;
          _pickupLocation ??= posPt;
          _otpService.pickupLocation ??= posPt;

          _recordHistoryPoint(posPt, accuracy: initialPos.accuracy);
          _checkRouteDeviation(posPt);

          if (_status != ParcelStatus.delivered) {
            _status = ParcelStatus.inTransit;
          }
          _lastUpdated = DateTime.now();
          _timeAgoText = 'Just now';
        });
      }

      await _locationService.startTracking(
        distanceFilter: 5, // 5-meter distance filter for meaningful movement
        onData: (position) {
          if (!mounted || _status == ParcelStatus.delivered) return;
          final pt = LatLng(position.latitude, position.longitude);
          setState(() {
            _currentLocation = pt;
            _pickupLocation ??= pt;
            _otpService.pickupLocation ??= pt;

            _recordHistoryPoint(pt, accuracy: position.accuracy);
            _checkRouteDeviation(pt);

            if (_status != ParcelStatus.delivered) {
              _status = ParcelStatus.inTransit;
            }
            _lastUpdated = DateTime.now();
            _timeAgoText = 'Just now';
          });
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _recordHistoryPoint(LatLng pt, {double? accuracy}) {
    // 1. Accuracy Filter: Ignore noisy/erratic GPS readings (> 35m accuracy)
    if (accuracy != null && accuracy > 35.0) {
      return;
    }

    // 2. Append to raw GPS history (source of truth)
    if (_rawGpsHistory.isEmpty || _rawGpsHistory.last != pt) {
      if (_rawGpsHistory.length >= 200) {
        _rawGpsHistory.removeAt(0);
      }
      _rawGpsHistory.add(pt);
    }

    // 3. Local Road-Snapping against OSRM planned route
    final snappedPt = RoutingService.snapPointToRoute(pt, _plannedRoute);

    if (_locationHistory.isEmpty || _locationHistory.last != snappedPt) {
      if (_locationHistory.length >= 200) {
        _locationHistory.removeAt(0);
      }
      _locationHistory.add(snappedPt);
      _otpService.locationHistory = _locationHistory;
    }
  }

  void _checkRouteDeviation(LatLng pt) {
    if (_plannedRoute.isEmpty) return;
    double minDistance = double.infinity;
    for (final rPt in _plannedRoute) {
      final d = Geolocator.distanceBetween(
        pt.latitude,
        pt.longitude,
        rPt.latitude,
        rPt.longitude,
      );
      if (d < minDistance) {
        minDistance = d;
      }
    }
    // Flag route deviation if traveller is > 1.5 km away from nearest OSRM route coordinate
    final isDeviated = minDistance > 1500.0;
    if (isDeviated != _isOffRoute) {
      setState(() {
        _isOffRoute = isDeviated;
      });
    }
  }

  /// Real Device GPS Refresh Triggered by AppBar Refresh Button
  Future<void> _refreshGpsLocation() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted) {
        final pt = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentLocation = pt;
          _pickupLocation ??= pt;
          _otpService.pickupLocation ??= pt;

          _recordHistoryPoint(pt, accuracy: position.accuracy);
          _checkRouteDeviation(pt);

          _lastUpdated = DateTime.now();
          _timeAgoText = 'Just now';
          _isRefreshing = false;
          if (_status == ParcelStatus.pickedUp) {
            _status = ParcelStatus.inTransit;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS location refreshed'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      final userErr = msg.contains('denied')
          ? 'Location permission is required for tracking.'
          : msg.contains('disabled')
              ? 'Please enable location services.'
              : 'Unable to update location.';

      setState(() {
        _isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userErr),
          backgroundColor: TravgoColors.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _stopGpsTracking() {
    _locationService.stopTracking();
  }

  void _navigateToDelivery() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeliveryOtpScreen(trip: widget.trip)),
    );
    if (mounted) {
      setState(() {
        if (_otpService.parcelStatus.name == 'delivered') {
          _status = ParcelStatus.delivered;
          _deliveryLocation = _otpService.deliveryLocation;
          if (_deliveryLocation != null) {
            _recordHistoryPoint(_deliveryLocation!);
          }
          _stopGpsTracking();
        }
      });
    }
  }

  // ─── Responsive Build Engine ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;

    Widget mainContent;

    // Dual-Pane Side-by-Side Layout for Landscape / Tablet / Desktop (>600px width AND landscape)
    if (screenWidth >= 760 || (screenWidth >= 600 && isLandscape)) {
      mainContent = Row(
        children: [
          // Left Pane (65% width): Hero Satellite Map
          Expanded(
            flex: 65,
            child: Stack(
              children: [
                Positioned.fill(
                  child: TrackingMap(
                    sourceName: _sourceName,
                    destinationName: _destinationName,
                    sourceLocation: _sourceLocation,
                    destinationLocation: _destinationLocation,
                    pickupLocation: _pickupLocation,
                    deliveryLocation: _deliveryLocation,
                    locationHistory: _locationHistory,
                    plannedRoute: _plannedRoute,
                    alternativeRoutes: _alternativeRoutes,
                    currentLocation: _currentLocation,
                    isFollowingTraveller: _isFollowingTraveller,
                    onUserPanned: () {
                      if (_isFollowingTraveller) {
                        setState(() {
                          _isFollowingTraveller = false;
                        });
                      }
                    },
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildDarkOverlayAppBar(),
                ),
                if (_routingError != null)
                  Positioned(
                    top: 85,
                    left: 16,
                    right: 80,
                    child: _buildRoutingErrorBanner(),
                  )
                else if (_isOffRoute && _status != ParcelStatus.delivered)
                  Positioned(
                    top: 85,
                    left: 16,
                    right: 80,
                    child: _buildRouteDeviationBanner(),
                  ),
              ],
            ),
          ),

          // Right Pane (35% width): Navigation Details Card
          SizedBox(
            width: (screenWidth * 0.35).clamp(320.0, 440.0),
            child: Container(
              color: const Color(0xF00F172A),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildSidePanelContent(),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Mobile / Tablet Portrait Vertical Overlay Layout
      mainContent = Stack(
        children: [
          // Hero Map
          Positioned.fill(
            child: TrackingMap(
              sourceName: _sourceName,
              destinationName: _destinationName,
              sourceLocation: _sourceLocation,
              destinationLocation: _destinationLocation,
              pickupLocation: _pickupLocation,
              deliveryLocation: _deliveryLocation,
              locationHistory: _locationHistory,
              plannedRoute: _plannedRoute,
              alternativeRoutes: _alternativeRoutes,
              currentLocation: _currentLocation,
              isFollowingTraveller: _isFollowingTraveller,
              onUserPanned: () {
                if (_isFollowingTraveller) {
                  setState(() {
                    _isFollowingTraveller = false;
                  });
                }
              },
              height: double.infinity,
            ),
          ),

          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildDarkOverlayAppBar(),
          ),

          // Alerts
          if (_routingError != null)
            Positioned(
              top: 85,
              left: 16,
              right: 80,
              child: _buildRoutingErrorBanner(),
            )
          else if (_isOffRoute && _status != ParcelStatus.delivered)
            Positioned(
              top: 85,
              left: 16,
              right: 80,
              child: _buildRouteDeviationBanner(),
            ),

          // Compact Bottom Panel (~25% height max)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCompactBottomPanel(),
          ),
        ],
      );
    }

    // Centered Desktop / Web Surface for large displays (>= 1200px)
    if (screenWidth >= 1200) {
      return Scaffold(
        backgroundColor: const Color(0xFF020617), // Deep charcoal outer fill
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1360),
            child: mainContent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: mainContent,
    );
  }

  // ─── Layer 1: App Bar ─────────────────────────────────────────────────────

  Widget _buildDarkOverlayAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 12,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Live Tracking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (_isRouteLoading) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '• Calculating route...',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF60A5FA),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Parcel #$_parcelId',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          _isRefreshing || _isRouteLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                  tooltip: 'Refresh GPS',
                  onPressed: _refreshGpsLocation,
                ),
        ],
      ),
    );
  }

  Widget _buildRoutingErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xF078350F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFCD34D), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _routingError ?? 'Unable to calculate route',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDeviationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xF0991B1B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Route deviation detected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _plannedRoute.clear();
              _fetchPlannedRoute();
            },
            child: const Text(
              'Recalculate',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFCA5A5),
                decoration: TextDecoration.underline,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Layer 3: Compact Bottom Panel (Mobile / Portrait) ────────────────────

  Widget _buildCompactBottomPanel() {
    final isDelivered = _status == ParcelStatus.delivered;
    final isReached = _hasReachedDestination;

    final coordsText = _currentLocation != null
        ? '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
        : 'Acquiring GPS...';

    final distText = _roadDistanceText ??
        (_distanceToDestinationMeters != null
            ? (_distanceToDestinationMeters! >= 1000
                ? 'Approx. ${(_distanceToDestinationMeters! / 1000).toStringAsFixed(1)} km'
                : 'Approx. ${_distanceToDestinationMeters!.round()} m')
            : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xF00F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header + Route Strip
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDelivered
                        ? const Color(0xFF10B981)
                        : isReached
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isDelivered
                        ? 'DELIVERY COMPLETED'
                        : isReached
                            ? 'DESTINATION REACHED'
                            : 'TRACKING ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: isDelivered
                          ? const Color(0xFF10B981)
                          : isReached
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF3B82F6),
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$_sourceName → $_destinationName',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 10),

            _buildHorizontalProgressTimeline(isReached: isReached, isDelivered: isDelivered),

            const SizedBox(height: 10),

            // GPS Coordinates & Distance Line
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$coordsText • $_timeAgoText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (distText != null && !isDelivered) ...[
                  Flexible(
                    child: Text(
                      _roadDurationText != null ? '$distText • $_roadDurationText' : distText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF60A5FA),
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            _buildCompactActionButton(isReached: isReached, isDelivered: isDelivered),
          ],
        ),
      ),
    );
  }

  // ─── Side Panel (Landscape / Tablet / Desktop) ────────────────────────────

  Widget _buildSidePanelContent() {
    final isDelivered = _status == ParcelStatus.delivered;
    final isReached = _hasReachedDestination;

    final coordsText = _currentLocation != null
        ? '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
        : 'Acquiring GPS...';

    final distText = _roadDistanceText ??
        (_distanceToDestinationMeters != null
            ? (_distanceToDestinationMeters! >= 1000
                ? 'Approx. ${(_distanceToDestinationMeters! / 1000).toStringAsFixed(1)} km'
                : 'Approx. ${_distanceToDestinationMeters!.round()} m')
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isDelivered
                    ? const Color(0xFF10B981)
                    : isReached
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isDelivered
                  ? 'DELIVERY COMPLETED'
                  : isReached
                      ? 'DESTINATION REACHED'
                      : 'TRACKING ACTIVE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDelivered
                    ? const Color(0xFF10B981)
                    : isReached
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF3B82F6),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Text(
          'Parcel #$_parcelId',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_sourceName → $_destinationName',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF60A5FA),
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 16),
        const Divider(color: Color(0xFF334155)),
        const SizedBox(height: 16),

        _buildHorizontalProgressTimeline(isReached: isReached, isDelivered: isDelivered),

        const SizedBox(height: 20),
        const Text(
          'LIVE METRICS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GPS Fix', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      coordsText,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Last Updated', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  Text(_timeAgoText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
              if (distText != null && !isDelivered) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Road Distance', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        distText,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF60A5FA)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildCompactActionButton(isReached: isReached, isDelivered: isDelivered),
      ],
    );
  }

  Widget _buildHorizontalProgressTimeline({
    required bool isReached,
    required bool isDelivered,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _horizontalNode('Pickup', true, false),
          _horizontalConnector(true),
          _horizontalNode('In Transit', !isReached && !isDelivered, isReached || isDelivered),
          _horizontalConnector(isReached || isDelivered),
          _horizontalNode('Delivery', isReached && !isDelivered, isDelivered),
        ],
      ),
    );
  }

  Widget _horizontalNode(String label, bool isActive, bool isDone) {
    final color = isDone
        ? const Color(0xFF10B981)
        : isActive
            ? const Color(0xFF3B82F6)
            : const Color(0xFF64748B);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF10B981)
                : isActive
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 8)
                : isActive
                    ? Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive || isDone ? FontWeight.w600 : FontWeight.w400,
            color: isDone || isActive ? Colors.white : const Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _horizontalConnector(bool isDone) {
    return Container(
      width: 24,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDone ? const Color(0xFF10B981) : const Color(0xFF334155),
    );
  }

  Widget _buildCompactActionButton({
    required bool isReached,
    required bool isDelivered,
  }) {
    if (isDelivered) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF065F46).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF059669)),
        ),
        child: const Center(
          child: Text(
            '✓ Handover Verified via OTP • Delivery Complete',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34D399),
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    }

    if (isReached) {
      return SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton.icon(
          onPressed: _navigateToDelivery,
          icon: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
          label: const Text(
            'Verify Delivery',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _simulateDestinationArrival = !_simulateDestinationArrival;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_simulateDestinationArrival
                ? 'Simulated arrival within 100m threshold'
                : 'Reset to real GPS distance'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: Icon(
        _simulateDestinationArrival
            ? Icons.undo_rounded
            : Icons.sports_score_rounded,
        size: 14,
        color: const Color(0xFF60A5FA),
      ),
      label: Text(
        _simulateDestinationArrival
            ? 'Reset GPS Distance'
            : 'Simulate Reaching Destination (<100m)',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF60A5FA),
          fontFamily: 'Inter',
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(36),
        side: const BorderSide(color: Color(0xFF3B82F6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
