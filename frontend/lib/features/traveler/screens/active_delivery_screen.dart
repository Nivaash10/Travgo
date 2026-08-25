import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parcel_request.dart';
import '../../tracking/services/location_service.dart';
import '../../sender/data/sender_mock_booking_data.dart';
import '../../sender/data/sender_mock_delivery_completion_data.dart';
import '../../sender/models/sender_delivery_status.dart';
import '../../sender/screens/sender_proof_viewer_screen.dart';
import 'traveller_rate_sender_screen.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final ParcelRequest? request;

  const ActiveDeliveryScreen({
    super.key,
    this.request,
  });

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  Position? _currentPosition;
  String? _locationError;
  StreamSubscription<Position>? _positionSub;
  Timer? _refreshTimer;

  final List<TextEditingController> _pControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pFocusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _dControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _dFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    final status = _getCurrentStatus();
    final isPickupVerified = status == SenderDeliveryStatus.inTransit ||
        status == SenderDeliveryStatus.pickedUp ||
        status == SenderDeliveryStatus.delivered;
    if (isPickupVerified && status != SenderDeliveryStatus.delivered) {
      _initDeviceLocation();
    }
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (var c in _pControllers) {
      c.dispose();
    }
    for (var f in _pFocusNodes) {
      f.dispose();
    }
    for (var c in _dControllers) {
      c.dispose();
    }
    for (var f in _dFocusNodes) {
      f.dispose();
    }
    _positionSub?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyPickupInline() async {
    final entered = _pControllers.map((c) => c.text.trim()).join();
    if (entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits.')),
      );
      return;
    }
    const expected = '4827';
    if (entered != expected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Pickup OTP. Please check code with sender.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    for (var b in SenderMockBookingData.getMockBookings()) {
      if (b.status == SenderDeliveryStatus.accepted ||
          b.status == SenderDeliveryStatus.pending ||
          b.status == SenderDeliveryStatus.pickupPending) {
        SenderMockBookingData.updateBookingStatus(b.id, SenderDeliveryStatus.inTransit);
      }
    }
    await _initDeviceLocation();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Pickup Verified! Real GPS Tracking Active.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _verifyDeliveryInline() async {
    final entered = _dControllers.map((c) => c.text.trim()).join();
    if (entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits.')),
      );
      return;
    }
    const expected = '7194';
    if (entered != expected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Delivery OTP. Please request code from receiver.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    LocationService().stopTracking();
    await _positionSub?.cancel();
    _positionSub = null;
    for (var b in SenderMockBookingData.getMockBookings()) {
      if (b.status == SenderDeliveryStatus.inTransit ||
          b.status == SenderDeliveryStatus.pickedUp ||
          b.status == SenderDeliveryStatus.accepted) {
        SenderMockBookingData.updateBookingStatus(b.id, SenderDeliveryStatus.delivered);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Delivery Verified! Escrow Funds Released.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _initDeviceLocation() async {
    try {
      final service = LocationService();
      final pos = await service.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = pos;
          _locationError = null;
        });
      }
      _positionSub = service.getPositionStream().listen(
        (p) {
          if (mounted) {
            setState(() {
              _currentPosition = p;
              _locationError = null;
            });
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() {
              _locationError = err.toString();
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
        });
      }
    }
  }

  SenderDeliveryStatus _getCurrentStatus() {
    final activeBookings = SenderMockBookingData.getMockBookings();
    if (activeBookings.isNotEmpty) {
      return activeBookings.first.status;
    }
    return SenderDeliveryStatus.accepted;
  }

  @override
  Widget build(BuildContext context) {
    final displayRequest = widget.request ??
        ParcelRequest(
          id: 'req_1',
          tripId: 'trip_1',
          senderName: 'Ramesh Kumar',
          parcelDescription: 'Electronics & Laptop Charger',
          parcelWeight: 2.0,
          source: 'Coimbatore',
          destination: 'Chennai',
          price: 250.0,
          status: 'ACCEPTED',
        );

    final currentStatus = _getCurrentStatus();
    final isPickupVerified = currentStatus == SenderDeliveryStatus.inTransit ||
        currentStatus == SenderDeliveryStatus.pickedUp ||
        currentStatus == SenderDeliveryStatus.delivered;
    final isInTransit = currentStatus == SenderDeliveryStatus.inTransit ||
        currentStatus == SenderDeliveryStatus.delivered;
    final isDelivered = currentStatus == SenderDeliveryStatus.delivered;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Active Delivery',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Status Pipeline
            const Text(
              'ACTIVE DELIVERY STATUS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusPipeline(
              isPickupVerified: isPickupVerified,
              isInTransit: isInTransit,
              isDelivered: isDelivered,
            ),

            const SizedBox(height: 20),

            // Location Permission / Error Alert
            if (_locationError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: Color(0xFFDC2626), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _locationError!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Parcel Information Card
            _buildParcelInformationCard(displayRequest),

            const SizedBox(height: 16),

            // 3. Route Card
            _buildRouteCard(displayRequest),

            const SizedBox(height: 16),

            // 4. Pickup Section (if not yet verified)
            if (!isPickupVerified) ...[
              _buildPickupOtpSection(context, displayRequest),
              const SizedBox(height: 16),
            ],

            // 5. Live Location Section (NO MAP on Traveller View)
            if (isPickupVerified && !isDelivered) ...[
              _buildLiveLocationCard(),
              const SizedBox(height: 16),
            ],

            // 6. Delivery Section
            if (isInTransit && !isDelivered) ...[
              _buildDeliveryOtpSection(context, displayRequest),
              const SizedBox(height: 16),
            ],

            // 7. Completed Delivery State
            if (isDelivered) ...[
              _buildDeliveryCompletedCard(displayRequest),
              const SizedBox(height: 16),
            ],

            // 8. Basic Trip Summary Card
            _buildTripSummaryCard(displayRequest),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPipeline({
    required bool isPickupVerified,
    required bool isInTransit,
    required bool isDelivered,
  }) {
    final stages = [
      {'title': 'Accepted', 'isCompleted': true, 'isCurrent': !isPickupVerified},
      {'title': 'Pickup verified', 'isCompleted': isPickupVerified, 'isCurrent': isPickupVerified && !isInTransit},
      {'title': 'In Transit', 'isCompleted': isInTransit, 'isCurrent': isInTransit && !isDelivered},
      {'title': 'Delivered', 'isCompleted': isDelivered, 'isCurrent': isDelivered},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final stage = stages[index];
          final isCompleted = stage['isCompleted'] as bool;
          final isCurrent = stage['isCurrent'] as bool;
          final isLast = index == stages.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? successColor
                          : isCurrent
                              ? primaryColor
                              : const Color(0xFFE2E8F0),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : isCurrent
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28,
                      color: isCompleted ? successColor : const Color(0xFFE2E8F0),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  stage['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent
                        ? primaryColor
                        : isCompleted
                            ? textColor
                            : subtitleColor,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLiveLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: successColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, color: successColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'LIVE LOCATION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: successColor),
                    SizedBox(width: 5),
                    Text(
                      'Tracking Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentPosition != null
                ? 'Current Position: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                : 'Acquiring device location...',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: Just now',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelInformationCard(ParcelRequest req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parcel Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.parcelDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sender: ${req.senderName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  '${req.parcelWeight} kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(ParcelRequest req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Route',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                req.source,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded, color: subtitleColor, size: 16),
              ),
              const Icon(Icons.place_rounded, color: secondaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                req.destination,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputRow(List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 52,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            decoration: InputDecoration(
              counterText: '',
              fillColor: cardColor,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && index < 3) {
                focusNodes[index + 1].requestFocus();
              } else if (val.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildPickupOtpSection(BuildContext context, ParcelRequest req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pin_outlined, color: accentColor, size: 20),
              SizedBox(width: 8),
              Text(
                'PICKUP OTP VERIFICATION',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the 4-digit pickup OTP provided by the sender upon parcel pickup',
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 16),
          _buildOtpInputRow(_pControllers, _pFocusNodes),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _verifyPickupInline,
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Verify Pickup', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOtpSection(BuildContext context, ParcelRequest req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: secondaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'DELIVERY OTP VERIFICATION',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the delivery code provided by the receiver to complete delivery & release payment',
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 16),
          _buildOtpInputRow(_dControllers, _dFocusNodes),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _verifyDeliveryInline,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Verify Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCompletedCard(ParcelRequest req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: successColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVERY COMPLETED ✓',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '✓ Pickup Verified  •  ✓ In Transit\n✓ Delivery OTP Verified  •  ✓ Delivered\nGPS: Tracking Off  •  Earnings: Payment Released (₹250)',
                      style: TextStyle(fontSize: 12, color: Color(0xFF047857), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final completion = SenderMockDeliveryCompletionData.getCompletionForBooking(req.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SenderProofViewerScreen(completion: completion),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_outlined, size: 16),
                  label: const Text(
                    'View Proof',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TravellerRateSenderScreen(
                          bookingId: req.id,
                          senderName: req.senderName,
                          senderId: 'SND-101',
                          route: '${req.source} → ${req.destination}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_rounded, size: 16),
                  label: const Text(
                    'Rate Sender',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(ParcelRequest req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Info',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agreed Price',
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
              Text(
                '₹${req.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trip ID',
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
              Text(
                req.tripId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
