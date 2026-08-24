/// Tracking Map Widget — Phase 2 Step 4 (OpenStreetMap Migration)
///
/// Mobile-first map container using `flutter_map` & OpenStreetMap.
/// Displays source marker, destination marker, current traveller marker, and prototype route.
/// Requires NO Google Maps API key or payment setup.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../otp/widgets/travgo_theme.dart';

class TrackingMap extends StatefulWidget {
  const TrackingMap({
    super.key,
    this.currentLocation,
    this.sourceLocation,
    this.destinationLocation,
    this.sourceName = 'Source',
    this.destinationName = 'Destination',
    this.height = 240,
  });

  final LatLng? currentLocation;
  final LatLng? sourceLocation;
  final LatLng? destinationLocation;
  final String sourceName;
  final String destinationName;
  final double height;

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation ||
        oldWidget.sourceLocation != widget.sourceLocation ||
        oldWidget.destinationLocation != widget.destinationLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ─── Points & Bounds ───────────────────────────────────────────────────────

  List<LatLng> get _polylinePoints {
    final points = <LatLng>[];
    if (widget.sourceLocation != null) points.add(widget.sourceLocation!);
    if (widget.currentLocation != null) points.add(widget.currentLocation!);
    if (widget.destinationLocation != null) {
      points.add(widget.destinationLocation!);
    }
    return points;
  }

  LatLng get _initialCenter {
    if (widget.currentLocation != null) return widget.currentLocation!;
    if (widget.sourceLocation != null) return widget.sourceLocation!;
    if (widget.destinationLocation != null) return widget.destinationLocation!;
    return const LatLng(11.0168, 76.9558); // Fallback: Coimbatore
  }

  void _fitBounds() {
    final points = _polylinePoints;
    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 13.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40.0),
      ),
    );
  }

  // ─── Markers ─────────────────────────────────────────────────────────────

  List<Marker> get _markers {
    final markers = <Marker>[];

    // Source Marker (Orange)
    if (widget.sourceLocation != null) {
      markers.add(
        Marker(
          point: widget.sourceLocation!,
          width: 80,
          height: 52,
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
                child: Text(
                  widget.sourceName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TravgoColors.warning,
                  ),
                  overflow: TextOverflow.ellipsis,
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
    }

    // Destination Marker (Green)
    if (widget.destinationLocation != null) {
      markers.add(
        Marker(
          point: widget.destinationLocation!,
          width: 80,
          height: 52,
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

    // Traveller Marker (Primary Blue with pulse ring)
    if (widget.currentLocation != null) {
      markers.add(
        Marker(
          point: widget.currentLocation!,
          width: 80,
          height: 52,
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
                  'Traveller',
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
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: TravgoColors.primary.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.sourceLocation == null &&
        widget.destinationLocation == null &&
        widget.currentLocation == null) {
      return _buildEmptyPlaceholder();
    }

    final polylinePoints = _polylinePoints;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: TravgoColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TravgoColors.border),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: 11.0,
                onMapReady: () {
                  _fitBounds();
                },
              ),
              children: [
                // OpenStreetMap Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.travgo.app',
                ),

                // Polyline Layer (Source -> Traveller -> Destination)
                if (polylinePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        color: TravgoColors.primary,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),

                // Marker Layer
                MarkerLayer(markers: _markers),

                // OpenStreetMap Attribution
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),

            // Top Status Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TravgoColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.currentLocation != null
                            ? TravgoColors.primary
                            : TravgoColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.currentLocation != null
                          ? 'Traveller active'
                          : 'Awaiting traveller GPS',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TravgoColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: TravgoColors.scaffoldBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TravgoColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: TravgoColors.primaryBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: TravgoColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Waiting for location data...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TravgoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Map will update when tracking starts',
                style: TextStyle(
                  fontSize: 11,
                  color: TravgoColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
