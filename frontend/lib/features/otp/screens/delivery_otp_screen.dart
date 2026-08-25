/// Delivery OTP Screen — Fully Responsive Premium Mobile OTP UI
///
/// Mobile-first verification card UI. 4 separate PIN boxes with dynamic responsive sizing, auto-focus, backspace support.
/// Preserves 100% of underlying OtpService & OtpModel verification logic.
///
/// Mock OTP: 7194
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../sender/data/sender_mock_booking_data.dart';
import '../../sender/models/sender_delivery_status.dart';
import '../../tracking/services/location_service.dart';
import '../../tracking/models/tracking_model.dart' hide ParcelStatus;
import '../../../models/travgo_delivery_booking.dart';
import '../../ratings/screens/rating_screen.dart';
import '../models/otp_model.dart';
import '../services/otp_service.dart';
import '../widgets/travgo_theme.dart';

class DeliveryOtpScreen extends StatefulWidget {
  final ParcelTrip? trip;
  final TravgoDeliveryBooking? booking;

  const DeliveryOtpScreen({
    super.key,
    this.trip,
    this.booking,
  });

  @override
  State<DeliveryOtpScreen> createState() => _DeliveryOtpScreenState();
}

class _DeliveryOtpScreenState extends State<DeliveryOtpScreen> {
  // ─── Service & State ──────────────────────────────────────────────────────
  final OtpService _service = OtpService.instance;
  late OtpModel _otpModel;

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  OtpVerifyResult? _lastResult;
  bool _verified = false;

  String get _enteredOtp =>
      _controllers.map((c) => c.text.trim()).join();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _otpModel = _service.generateDeliveryOtp();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Timer ───────────────────────────────────────────────────────────────

  void _startCountdown() {
    _updateRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_updateRemaining);
    });
  }

  void _updateRemaining() {
    final expires = _service.deliveryOtpExpiresAt;
    if (expires == null) return;
    final diff = expires.difference(DateTime.now());
    _remaining = diff.isNegative ? Duration.zero : diff;
  }

  String get _timerLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isExpired => _remaining == Duration.zero;

  // ─── Verification ─────────────────────────────────────────────────────────

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final entered = _enteredOtp;
    if (entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits.')),
      );
      return;
    }
    final expectedOtp = widget.booking?.deliveryOtp ?? _otpModel.otp;
    final result = _service.verifyDeliveryOtp(entered, expectedOtp: expectedOtp);
    if (result == OtpVerifyResult.success) {
      LocationService().stopTracking();
      for (var b in SenderMockBookingData.getMockBookings()) {
        if (b.status == SenderDeliveryStatus.pickedUp || b.status == SenderDeliveryStatus.inTransit || b.status == SenderDeliveryStatus.accepted) {
          SenderMockBookingData.updateBookingStatus(b.id, SenderDeliveryStatus.delivered);
        }
      }
      try {
        final pos = await LocationService().getCurrentLocation();
        _service.deliveryLocation = LatLng(pos.latitude, pos.longitude);
      } catch (_) {
        _service.deliveryLocation = const LatLng(13.0827, 80.2707);
      }
    }
    setState(() {
      _lastResult = result;
      _verified = result == OtpVerifyResult.success;
    });
    if (_verified) _countdownTimer?.cancel();
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────

  Color get _errorColor {
    switch (_lastResult) {
      case OtpVerifyResult.wrongOtp:    return TravgoColors.error;
      case OtpVerifyResult.expired:     return TravgoColors.warning;
      case OtpVerifyResult.alreadyUsed: return TravgoColors.purple;
      default:                          return TravgoColors.error;
    }
  }

  Color get _errorBg {
    switch (_lastResult) {
      case OtpVerifyResult.wrongOtp:    return TravgoColors.errorBg;
      case OtpVerifyResult.expired:     return TravgoColors.warningBg;
      case OtpVerifyResult.alreadyUsed: return TravgoColors.purpleBg;
      default:                          return TravgoColors.errorBg;
    }
  }

  String get _errorTitle {
    switch (_lastResult) {
      case OtpVerifyResult.wrongOtp:    return 'Invalid OTP';
      case OtpVerifyResult.expired:     return 'OTP Expired';
      case OtpVerifyResult.alreadyUsed: return 'OTP Already Used';
      default:                          return 'Verification Error';
    }
  }

  String get _errorSubtitle {
    switch (_lastResult) {
      case OtpVerifyResult.wrongOtp:    return 'Please check the code and try again.';
      case OtpVerifyResult.expired:     return 'Request a new code to continue.';
      case OtpVerifyResult.alreadyUsed: return 'This verification code is no longer valid.';
      default:                          return '';
    }
  }

  ParcelStatusUi get _statusUi {
    switch (_service.parcelStatus) {
      case ParcelStatus.paymentConfirmed: return ParcelStatusUi.paymentConfirmed;
      case ParcelStatus.pickedUp:         return ParcelStatusUi.pickedUp;
      case ParcelStatus.delivered:        return ParcelStatusUi.delivered;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravgoColors.scaffoldBg,
      appBar: travgoAppBar('Verify Delivery'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: TravgoColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: TravgoColors.border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_verified) ...[
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildParcelContextCard(),
                    const SizedBox(height: 16),
                    _buildOtpBoxes(),
                    const SizedBox(height: 14),
                    _buildTimerRow(),
                    if (_lastResult != null && _lastResult != OtpVerifyResult.success) ...[
                      const SizedBox(height: 14),
                      _buildErrorContainer(),
                    ],
                    const SizedBox(height: 18),
                    TravgoPrimaryButton(
                      label: 'Verify Delivery',
                      onPressed: (_isExpired || _enteredOtp.length < 4) ? null : _verify,
                    ),
                    const SizedBox(height: 16),
                    _buildResendRow(),
                    const SizedBox(height: 8),
                    _buildHelpButton(),
                  ] else ...[
                    _buildSuccessState(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Component Widgets ────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: TravgoColors.successBg,
            shape: BoxShape.circle,
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.markunread_mailbox_outlined,
                  color: TravgoColors.success, size: 24),
              Positioned(
                right: 10,
                bottom: 10,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: TravgoColors.success,
                  child: Icon(Icons.check, color: Colors.white, size: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Verify Delivery',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: TravgoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter the 4-digit OTP provided by the receiver to confirm parcel delivery.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: TravgoColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildParcelContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TravgoColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TravgoColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TravgoColors.border),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: TravgoColors.success, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parcel #${widget.trip?.parcelId ?? widget.booking?.parcelId ?? _otpModel.parcelId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TravgoColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Destination: ${widget.trip?.destinationName ?? widget.booking?.destinationName ?? "Chennai"}',
                  style: const TextStyle(fontSize: 11, color: TravgoColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Column(
      children: [
        const Text(
          'Enter Delivery OTP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TravgoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildSingleOtpBox(index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleOtpBox(int index) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      },
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: TravgoColors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _controllers[index].text.isNotEmpty
              ? TravgoColors.successBg
              : TravgoColors.inputBg,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _controllers[index].text.isNotEmpty
                  ? TravgoColors.success
                  : TravgoColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: TravgoColors.success,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          }
        },
      ),
    );
  }

  Widget _buildTimerRow() {
    final isWarning = _remaining.inSeconds < 60 && !_isExpired;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
          size: 14,
          color: _isExpired
              ? TravgoColors.error
              : isWarning
                  ? TravgoColors.warning
                  : TravgoColors.textSecondary,
        ),
        const SizedBox(width: 5),
        Text(
          _isExpired ? 'OTP expired' : 'Expires in $_timerLabel',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _isExpired
                ? TravgoColors.error
                : isWarning
                    ? TravgoColors.warning
                    : TravgoColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _errorColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _errorTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _errorColor,
                  ),
                ),
                if (_errorSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    _errorSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: _errorColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendRow() {
    return Column(
      children: [
        const Text(
          "Didn't receive the code?",
          style: TextStyle(fontSize: 12, color: TravgoColors.textSecondary),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please request the receiver to share the OTP.'),
              ),
            );
          },
          child: const Text(
            'Ask the receiver to resend',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TravgoColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: TravgoColors.textSecondary,
      ),
      child: const Text(
        'Need help?',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: TravgoColors.successBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: TravgoColors.success, size: 32),
        ),
        const SizedBox(height: 14),
        const Text(
          'Delivery Confirmed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TravgoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'The parcel has been successfully delivered to the receiver.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: TravgoColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TravgoColors.scaffoldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TravgoColors.border),
          ),
          child: Column(
            children: [
              const Text('Parcel Status', style: TravgoText.caption),
              const SizedBox(height: 6),
              ParcelStatusChip(status: _statusUi),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TravgoPrimaryButton(
          label: 'Proceed to Payment Release & Rating',
          icon: Icons.star_rounded,
          color: TravgoColors.success,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RatingScreen(
                  parcelId: widget.trip?.parcelId ?? widget.booking?.parcelId ?? _otpModel.parcelId,
                  travellerId: widget.booking?.travellerId ?? 'TRV-501',
                  travellerName: widget.trip?.travellerName ?? widget.booking?.travellerName ?? 'Arun Kumar',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
