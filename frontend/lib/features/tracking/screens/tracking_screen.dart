/// Complete Tracking Screen — Mobile-First Redesign & Refresh Fix
///
/// Mobile-first live tracking screen with real GPS refresh, OpenStreetMap,
/// compact vertical timeline, location details, and Delivery OTP transition.
/// Uses standard StatefulWidget + LocationService. Zero state-management packages added.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../otp/screens/delivery_otp_screen.dart';
import '../../otp/services/otp_service.dart' hide ParcelStatus;
import '../../otp/widgets/travgo_theme.dart';
import '../models/tracking_model.dart';
import '../services/location_service.dart';
import '../widgets/tracking_map.dart';
import 'live_tracking_map_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final LocationService _locationService = LocationService();
  final OtpService _otpService = OtpService.instance;

  // Prototype route coordinates
  final LatLng _sourceLocation = const LatLng(11.0168, 76.9558); // Coimbatore
  final LatLng _destinationLocation = const LatLng(13.0827, 80.2707); // Chennai

  LatLng? _currentLocation;
  ParcelStatus _status = ParcelStatus.pickedUp;
  DateTime? _lastUpdated;

  bool _isLoadingGps = false;
  bool _isRefreshing = false;
  String? _gpsErrorMessage;
  Timer? _timerTicker;
  String _timeAgoText = 'Just now';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _syncStatusFromOtp();
    _startGpsTracking();
    _startTimerTicker();
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    _locationService.stopTracking();
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
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    final h = updated.hour.toString().padLeft(2, '0');
    final m = updated.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _syncStatusFromOtp() {
    if (_otpService.parcelStatus.name == 'delivered') {
      _status = ParcelStatus.delivered;
    } else if (_otpService.parcelStatus.name == 'pickedUp') {
      _status = ParcelStatus.pickedUp;
    }
  }

  // ─── GPS Operations ──────────────────────────────────────────────────────

  Future<void> _startGpsTracking() async {
    if (_status == ParcelStatus.delivered) return;

    setState(() {
      _isLoadingGps = true;
      _gpsErrorMessage = null;
    });

    try {
      await _locationService.verifyPermissionAndService();

      final initialPos = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(initialPos.latitude, initialPos.longitude);
          _status = ParcelStatus.inTransit;
          _lastUpdated = DateTime.now();
          _timeAgoText = 'Just now';
          _isLoadingGps = false;
        });
      }

      await _locationService.startTracking(
        onData: (position) {
          if (!mounted) return;
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
            _status = ParcelStatus.inTransit;
            _lastUpdated = DateTime.now();
            _timeAgoText = 'Just now';
            _isLoadingGps = false;
            _gpsErrorMessage = null;
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _gpsErrorMessage = 'Unable to update location';
            _isLoadingGps = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isLoadingGps = false;
        _gpsErrorMessage = msg.contains('denied')
            ? 'Location permission is required for tracking.'
            : msg.contains('disabled')
                ? 'Please enable location services.'
                : 'Unable to update location. Try again.';
      });
    }
  }

  /// Real GPS Refresh Triggered by AppBar Refresh Button
  Future<void> _refreshGpsLocation() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _gpsErrorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
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
        _gpsErrorMessage = userErr;
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  ParcelStatusUi get _statusUi {
    switch (_status) {
      case ParcelStatus.paymentConfirmed:
        return ParcelStatusUi.paymentConfirmed;
      case ParcelStatus.pickedUp:
        return ParcelStatusUi.pickedUp;
      case ParcelStatus.inTransit:
        return ParcelStatusUi.inTransit;
      case ParcelStatus.delivered:
        return ParcelStatusUi.delivered;
      default:
        return ParcelStatusUi.inTransit;
    }
  }

  void _navigateToDelivery() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeliveryOtpScreen()),
    );
    if (mounted) {
      setState(() {
        if (_otpService.parcelStatus.name == 'delivered') {
          _status = ParcelStatus.delivered;
          _stopGpsTracking();
        }
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravgoColors.scaffoldBg,
      appBar: travgoAppBar(
        'Track Parcel',
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TravgoColors.primary,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: TravgoColors.primary),
                  tooltip: 'Refresh GPS',
                  onPressed: _refreshGpsLocation,
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Prominent OpenStreetMap Container (Tap to Expand)
              _buildMapSection(),

              const SizedBox(height: 14),

              // 2. Compact Status & Parcel Info Card
              _buildParcelHeaderCard(),

              const SizedBox(height: 12),

              // 3. Compact Current Location Card
              _buildLocationCard(),

              const SizedBox(height: 12),

              // 4. Compact Vertical Timeline
              _buildVerticalTimeline(),

              const SizedBox(height: 16),

              // 5. Delivery Action / Success Card
              if (_status != ParcelStatus.delivered) ...[
                TravgoPrimaryButton(
                  label: 'Reached Destination — Verify Delivery',
                  icon: Icons.pin_drop_rounded,
                  onPressed: _navigateToDelivery,
                ),
              ] else ...[
                _buildDeliveredSuccessCard(),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Component Cards ──────────────────────────────────────────────────────

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveTrackingMapScreen(
              initialLocation: _currentLocation,
              sourceLocation: _sourceLocation,
              destinationLocation: _destinationLocation,
              sourceName: 'Coimbatore',
              destinationName: 'Chennai',
              parcelId: 'TRV1024',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            TrackingMap(
              sourceName: 'Coimbatore',
              destinationName: 'Chennai',
              sourceLocation: _sourceLocation,
              destinationLocation: _destinationLocation,
              currentLocation: _currentLocation,
              height: 290,
            ),

            // Tap hint badge
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: TravgoColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: TravgoColors.primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Expand Live Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

  Widget _buildParcelHeaderCard() {
    return TravgoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Parcel #TRV1024',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TravgoColors.textPrimary,
                ),
              ),
              const Spacer(),
              ParcelStatusChip(status: _statusUi),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: TravgoColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: TravgoColors.primary, size: 16),
              const SizedBox(width: 6),
              const Text('Coimbatore', style: TravgoText.bodyBold),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 14, color: TravgoColors.textSecondary),
              ),
              const Icon(Icons.location_on_rounded,
                  color: TravgoColors.success, size: 16),
              const SizedBox(width: 6),
              const Text('Chennai', style: TravgoText.bodyBold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final locationText = _currentLocation != null
        ? '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
        : _isLoadingGps
            ? 'Fetching GPS position...'
            : 'Location unavailable';

    return TravgoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TravgoColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.my_location_rounded,
                color: TravgoColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Location', style: TravgoText.caption),
                const SizedBox(height: 2),
                Text(
                  locationText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TravgoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Updated $_timeAgoText',
                  style: TextStyle(
                    fontSize: 11,
                    color: TravgoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_gpsErrorMessage != null)
            Tooltip(
              message: _gpsErrorMessage!,
              child: const Icon(Icons.info_outline_rounded,
                  color: TravgoColors.warning, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildVerticalTimeline() {
    final isPickedUp = _status == ParcelStatus.pickedUp ||
        _status == ParcelStatus.inTransit ||
        _status == ParcelStatus.delivered;
    final isDelivered = _status == ParcelStatus.delivered;


    return TravgoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Status', style: TravgoText.sectionTitle),
          const SizedBox(height: 14),
          _timelineNode(
            title: 'Picked Up',
            subtitle: 'Sender handoff verified via OTP',
            isDone: isPickedUp,
            isActive: _status == ParcelStatus.pickedUp,
            isLast: false,
          ),
          _timelineNode(
            title: 'In Transit',
            subtitle: 'Live GPS tracking active',
            isDone: isDelivered,
            isActive: _status == ParcelStatus.inTransit,
            isLast: false,
          ),
          _timelineNode(
            title: 'Delivered',
            subtitle: 'Receiver OTP handover',
            isDone: isDelivered,
            isActive: _status == ParcelStatus.delivered,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineNode({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isDone
        ? TravgoColors.success
        : isActive
            ? TravgoColors.primary
            : TravgoColors.textHint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone
                    ? TravgoColors.success
                    : isActive
                        ? TravgoColors.primary
                        : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 12)
                    : isActive
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isDone ? TravgoColors.success : TravgoColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive || isDone
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isDone
                      ? TravgoColors.textPrimary
                      : isActive
                          ? TravgoColors.primary
                          : TravgoColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TravgoText.caption,
              ),
              if (!isLast) const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveredSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TravgoColors.successBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TravgoColors.successBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: TravgoColors.success, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parcel Delivered',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TravgoColors.success,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Handover confirmed. GPS tracking completed.',
                  style: TextStyle(
                    fontSize: 12,
                    color: TravgoColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
