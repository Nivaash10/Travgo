/// Tracking Map Widget — Hybrid Satellite Navigation Canvas
///
/// Mobile navigation map using `flutter_map` with Hybrid Satellite layers:
///   - Layer 1: Esri World Imagery (Satellite Photo Base)
///   - Layer 2: Esri World Transportation (Roads & Highways Overlay)
///   - Layer 3: Esri World Boundaries and Places (Cities, Towns, & Place Labels Overlay)
///   - Layer 4: Alternative OSRM Routes (Subtle Slate/Gray Polylines)
///   - Layer 5: Planned Road-Following Route (Primary OSRM Geometry Polyline)
///   - Layer 6: Actual Travelled GPS Path (Solid Vibrant Blue Polyline)
///   - Layer 7: MarkerLayer (📦 Pickup, 🔵 Traveller, 📍 Destination, ✓ Delivered)
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_tile_config.dart';

class TrackingMap extends StatefulWidget {
  const TrackingMap({
    super.key,
    this.currentLocation,
    this.sourceLocation,
    this.destinationLocation,
    this.pickupLocation,
    this.deliveryLocation,
    this.locationHistory = const [],
    this.plannedRoute = const [],
    this.alternativeRoutes = const [],
    this.sourceName = 'Coimbatore',
    this.destinationName = 'Chennai',
    this.height = double.infinity,
    this.isFollowingTraveller = true,
    this.onUserPanned,
  });

  final LatLng? currentLocation;
  final LatLng? sourceLocation;
  final LatLng? destinationLocation;
  final LatLng? pickupLocation;
  final LatLng? deliveryLocation;
  final List<LatLng> locationHistory;
  final List<LatLng> plannedRoute;
  final List<List<LatLng>> alternativeRoutes;
  final String sourceName;
  final String destinationName;
  final double height;
  final bool isFollowingTraveller;
  final VoidCallback? onUserPanned;

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  final MapController _mapController = MapController();
  MapStyleMode _styleMode = MapStyleMode.hybridSatellite;

  String get _attributionText => _styleMode == MapStyleMode.hybridSatellite
      ? MapTileConfig.satelliteAttribution
      : MapTileConfig.streetsAttribution;

  @override
  void didUpdateWidget(covariant TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If auto-follow mode is active and traveller position updated, center camera smoothly
    if (widget.isFollowingTraveller &&
        widget.currentLocation != null &&
        oldWidget.currentLocation != widget.currentLocation) {
      _mapController.move(widget.currentLocation!, _mapController.camera.zoom);
      return;
    }

    // Auto-fit camera bounds ONLY on milestone status changes or new planned route load
    if (oldWidget.pickupLocation != widget.pickupLocation ||
        oldWidget.deliveryLocation != widget.deliveryLocation ||
        (oldWidget.plannedRoute.isEmpty && widget.plannedRoute.isNotEmpty) ||
        (oldWidget.sourceLocation != widget.sourceLocation) ||
        (oldWidget.destinationLocation != widget.destinationLocation) ||
        (oldWidget.currentLocation == null && widget.currentLocation != null)) {
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

  // ─── Polyline Calculations ──────────────────────────────────────────────────

  /// Solid polyline representing actual recorded GPS journey
  List<LatLng> get _travelledPathPoints {
    final points = <LatLng>[];

    final start = widget.pickupLocation ?? widget.sourceLocation;
    if (start != null) points.add(start);

    for (final pt in widget.locationHistory) {
      if (points.isEmpty || points.last != pt) {
        points.add(pt);
      }
    }

    final current = widget.deliveryLocation ?? widget.currentLocation;
    if (current != null) {
      if (points.isEmpty || points.last != current) {
        points.add(current);
      }
    }

    return points;
  }

  LatLng get _initialCenter {
    if (widget.currentLocation != null) return widget.currentLocation!;
    if (widget.pickupLocation != null) return widget.pickupLocation!;
    if (widget.deliveryLocation != null) return widget.deliveryLocation!;
    if (widget.sourceLocation != null) return widget.sourceLocation!;
    if (widget.destinationLocation != null) return widget.destinationLocation!;
    return const LatLng(11.0168, 76.9558); // Fallback: Coimbatore
  }

  void _fitBounds() {
    final points = <LatLng>[];
    if (widget.plannedRoute.isNotEmpty) {
      points.addAll(widget.plannedRoute);
    } else {
      points.addAll(_travelledPathPoints);
      if (widget.sourceLocation != null) points.add(widget.sourceLocation!);
      if (widget.destinationLocation != null) {
        points.add(widget.destinationLocation!);
      }
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 13.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  // ─── Markers ─────────────────────────────────────────────────────────────

  List<Marker> get _markers {
    final markers = <Marker>[];

    // 1. Pickup Marker (Fixed Orange Package Icon)
    final pickupPt = widget.pickupLocation ?? widget.sourceLocation;
    if (pickupPt != null) {
      markers.add(
        Marker(
          point: pickupPt,
          width: 70,
          height: 42,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  widget.sourceName,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 1),
              const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    // 2. Destination Marker (Fixed Red Pin — while not delivered)
    if (widget.destinationLocation != null && widget.deliveryLocation == null) {
      markers.add(
        Marker(
          point: widget.destinationLocation!,
          width: 70,
          height: 44,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  widget.destinationName,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 1),
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ],
          ),
        ),
      );
    }

    // 3. Delivered Marker (Fixed Green Check Pin — after Delivery OTP)
    if (widget.deliveryLocation != null) {
      markers.add(
        Marker(
          point: widget.deliveryLocation!,
          width: 70,
          height: 44,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  'Delivered',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    // 4. Current Traveller Marker (ONLY ONE active navigation blue dot with glow!)
    if (widget.currentLocation != null && widget.deliveryLocation == null) {
      markers.add(
        Marker(
          point: widget.currentLocation!,
          width: 50,
          height: 50,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
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
            ),
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
        widget.currentLocation == null &&
        widget.pickupLocation == null &&
        widget.deliveryLocation == null) {
      return _buildEmptyPlaceholder();
    }

    final travelled = _travelledPathPoints;
    final isFullScreen = widget.height == double.infinity;

    Widget mapBody = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 11.0,
            onMapReady: () {
              _fitBounds();
            },
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && widget.onUserPanned != null) {
                widget.onUserPanned!();
              }
            },
          ),
          children: [
            // Hybrid Tile Layers: Satellite Base + Roads Overlay + City/Place Labels Overlay
            ...MapTileConfig.buildTileLayers(_styleMode),

            // Polyline Layer (Alternative Routes + Primary OSRM Route + Actual Travelled Path)
            PolylineLayer(
              polylines: [
                // 1. ALTERNATIVE OSRM ROUTES (Subtle Slate/Gray Lines)
                if (widget.deliveryLocation == null)
                  for (final altPath in widget.alternativeRoutes)
                    if (altPath.length >= 2)
                      Polyline(
                        points: altPath,
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.35),
                        strokeWidth: 3.5,
                      ),

                // 2. PRIMARY PLANNED ROUTE (OSRM Road-Following Geometry)
                if (widget.plannedRoute.length >= 2 && widget.deliveryLocation == null)
                  Polyline(
                    points: widget.plannedRoute,
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                    strokeWidth: 4.0,
                  ),

                // 3. ACTUAL TRAVELLED PATH (Solid Vibrant Blue GPS Breadcrumbs)
                if (travelled.length >= 2)
                  Polyline(
                    points: travelled,
                    color: const Color(0xFF3B82F6),
                    strokeWidth: 5.0,
                  ),
              ],
            ),

            MarkerLayer(markers: _markers),

            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(_attributionText),
              ],
            ),
          ],
        ),

        // Floating Navigation Controls (Top-Right)
        Positioned(
          top: isFullScreen ? 85 : 12,
          right: 12,
          child: Column(
            children: [
              // Style Toggle Button (Hybrid Satellite / Streets)
              InkWell(
                onTap: () {
                  setState(() {
                    _styleMode = _styleMode == MapStyleMode.hybridSatellite
                        ? MapStyleMode.streets
                        : MapStyleMode.hybridSatellite;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xF00F172A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF334155)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    _styleMode == MapStyleMode.hybridSatellite
                        ? Icons.map_rounded
                        : Icons.satellite_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Recenter Button
              InkWell(
                onTap: () {
                  final target = widget.currentLocation ??
                      widget.pickupLocation ??
                      widget.sourceLocation;
                  if (target != null) {
                    _mapController.move(target, 14.0);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xF00F172A),
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.isFollowingTraveller
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF334155)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: widget.isFollowingTraveller
                        ? const Color(0xFF60A5FA)
                        : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isFullScreen) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: mapBody,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: mapBody,
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      height: widget.height == double.infinity ? 300 : widget.height,
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.satellite_alt_rounded,
                color: Color(0xFF3B82F6), size: 28),
            SizedBox(height: 8),
            Text(
              'Loading hybrid satellite map...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
