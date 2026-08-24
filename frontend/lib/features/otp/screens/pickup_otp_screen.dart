/// Pickup OTP Screen — Phase 1 (Premium Mobile OTP UI)
///
/// Mobile-first verification card UI. 4 separate PIN boxes, auto-focus, backspace support.
/// Preserves 100% of underlying OtpService & OtpModel verification logic.
///
/// Mock OTP: 4827
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../tracking/services/location_service.dart';
import '../models/otp_model.dart';
import '../services/otp_service.dart';
import '../widgets/travgo_theme.dart';
import '../../tracking/screens/tracking_screen.dart';






class PickupOtpScreen extends StatefulWidget {
  const PickupOtpScreen({super.key});

  @override
  State<PickupOtpScreen> createState() => _PickupOtpScreenState();
}

class _PickupOtpScreenState extends State<PickupOtpScreen> {
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
    _otpModel = _service.generatePickupOtp();
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
    final expires = _service.pickupOtpExpiresAt;
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
    final result = _service.verifyPickupOtp(entered);
    if (result == OtpVerifyResult.success) {
      try {
        final pos = await LocationService().getCurrentLocation();
        _service.pickupLocation = LatLng(pos.latitude, pos.longitude);
      } catch (_) {
        _service.pickupLocation = const LatLng(11.0168, 76.9558);
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
      appBar: travgoAppBar('Verify Pickup'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_verified) ...[
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildParcelContextCard(),
                    const SizedBox(height: 20),
                    _buildOtpBoxes(),
                    const SizedBox(height: 16),
                    _buildTimerRow(),
                    if (_lastResult != null && _lastResult != OtpVerifyResult.success) ...[
                      const SizedBox(height: 16),
                      _buildErrorContainer(),
                    ],
                    const SizedBox(height: 22),
                    TravgoPrimaryButton(
                      label: 'Verify Pickup',
                      onPressed: (_isExpired || _enteredOtp.length < 4) ? null : _verify,
                    ),
                    const SizedBox(height: 20),
                    _buildResendRow(),
                    const SizedBox(height: 12),
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
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: TravgoColors.primaryBg,
            shape: BoxShape.circle,
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: TravgoColors.primary, size: 30),
              Positioned(
                right: 14,
                bottom: 14,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: TravgoColors.primary,
                  child: Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Verify Pickup',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TravgoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter the 4-digit OTP shared by the sender to confirm parcel pickup.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: TravgoColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildParcelContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TravgoColors.scaffoldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TravgoColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TravgoColors.border),
            ),
            child: const Icon(Icons.local_shipping_outlined,
                color: TravgoColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parcel #${_otpModel.parcelId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TravgoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Text('Coimbatore', style: TravgoText.caption),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 12, color: TravgoColors.textSecondary),
                    ),
                    Text('Chennai', style: TravgoText.caption),
                  ],
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
          'Enter Pickup OTP',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TravgoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => _buildSingleOtpBox(index)),
        ),
      ],
    );
  }

  Widget _buildSingleOtpBox(int index) {
    return SizedBox(
      width: 58,
      height: 64,
      child: KeyboardListener(
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
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: TravgoColors.textPrimary,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: _controllers[index].text.isNotEmpty
                ? TravgoColors.primaryBg
                : TravgoColors.inputBg,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _controllers[index].text.isNotEmpty
                    ? TravgoColors.primary
                    : TravgoColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: TravgoColors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {}); // Re-evaluate button enable state
            if (value.isNotEmpty) {
              if (index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
              }
            }
          },
        ),
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
          size: 15,
          color: _isExpired
              ? TravgoColors.error
              : isWarning
                  ? TravgoColors.warning
                  : TravgoColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          _isExpired ? 'OTP expired' : 'Expires in $_timerLabel',
          style: TextStyle(
            fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _errorColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _errorTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _errorColor,
                  ),
                ),
                if (_errorSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _errorSubtitle,
                    style: TextStyle(
                      fontSize: 12,
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
                content: Text('Please request the sender to share the OTP.'),
              ),
            );
          },
          child: const Text(
            'Ask the sender to resend',
            style: TextStyle(
              fontSize: 13,
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
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: TravgoColors.successBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: TravgoColors.success, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pickup Verified',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TravgoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'The parcel has been successfully handed over to the traveller.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: TravgoColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 24),
        TravgoPrimaryButton(
          label: 'Continue to Tracking',
          icon: Icons.map_outlined,
          color: TravgoColors.success,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrackingScreen()),
            );
          },
        ),

      ],
    );
  }
}
