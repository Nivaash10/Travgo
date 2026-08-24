/// OTP Service — Phase 1
///
/// Provides mock OTP generation and verification for development/demo purposes.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// PHASE 1 NOTE:
///   OTPs are hard-coded mock values for SIH prototype demonstration.
///   The service is structured so that [generatePickupOtp] and
///   [generateDeliveryOtp] can later be replaced with HTTP calls to the
///   backend API without touching the screens.
///
///   Future backend flow:
///     Flutter → POST /otp/generate → backend generates OTP → stores in DB
///     Flutter → POST /otp/verify  → backend checks OTP   → updates status
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../models/otp_model.dart';

/// Result returned by every verify call so the screen can display the
/// correct message without knowing internal OTP state.
enum OtpVerifyResult {
  success,
  wrongOtp,
  expired,
  alreadyUsed,
}

/// Parcel status — minimal states needed for OTP Phase 1 testing.
/// DO NOT expand this enum until the tracking phase.
enum ParcelStatus {
  paymentConfirmed,
  pickedUp,
  delivered,
}

class OtpService {
  // ─── Mock OTP values (Phase 1 only) ────────────────────────────────────────
  static const String _mockPickupOtp = '4827';
  static const String _mockDeliveryOtp = '7194';
  static const String _parcelId = 'TRV1024';
  static const Duration _otpTtl = Duration(minutes: 5);

  // ─── Internal state ─────────────────────────────────────────────────────────
  OtpModel? _pickupOtp;
  OtpModel? _deliveryOtp;
  ParcelStatus _parcelStatus = ParcelStatus.paymentConfirmed;

  // ─── Singleton accessor (optional convenience) ───────────────────────────────
  static final OtpService instance = OtpService._();
  OtpService._();

  // ─── Status ──────────────────────────────────────────────────────────────────

  ParcelStatus get parcelStatus => _parcelStatus;

  // ─── Generation ──────────────────────────────────────────────────────────────

  /// Generates (or refreshes) the pickup OTP.
  /// In Phase 2+ this will call the backend and receive a real OTP.
  OtpModel generatePickupOtp() {
    _pickupOtp = OtpModel(
      parcelId: _parcelId,
      otpType: OtpType.pickup,
      otp: _mockPickupOtp,
      expiresAt: DateTime.now().add(_otpTtl),
    );
    return _pickupOtp!;
  }

  /// Generates (or refreshes) the delivery OTP.
  /// In Phase 2+ this will call the backend and receive a real OTP.
  OtpModel generateDeliveryOtp() {
    _deliveryOtp = OtpModel(
      parcelId: _parcelId,
      otpType: OtpType.delivery,
      otp: _mockDeliveryOtp,
      expiresAt: DateTime.now().add(_otpTtl),
    );
    return _deliveryOtp!;
  }

  // ─── Verification ─────────────────────────────────────────────────────────

  /// Verifies the pickup OTP entered by the traveller.
  /// Returns an [OtpVerifyResult] describing the outcome.
  OtpVerifyResult verifyPickupOtp(String entered) {
    final otp = _pickupOtp;
    if (otp == null) return OtpVerifyResult.wrongOtp;

    if (otp.isUsed) return OtpVerifyResult.alreadyUsed;
    if (otp.isExpired) return OtpVerifyResult.expired;
    if (entered.trim() != otp.otp) return OtpVerifyResult.wrongOtp;

    // Correct, unexpired, unused — mark consumed and advance status.
    otp.markUsed();
    _parcelStatus = ParcelStatus.pickedUp;
    return OtpVerifyResult.success;
  }

  /// Verifies the delivery OTP entered by the traveller.
  /// The delivery OTP is completely independent from the pickup OTP.
  OtpVerifyResult verifyDeliveryOtp(String entered) {
    final otp = _deliveryOtp;
    if (otp == null) return OtpVerifyResult.wrongOtp;

    if (otp.isUsed) return OtpVerifyResult.alreadyUsed;
    if (otp.isExpired) return OtpVerifyResult.expired;
    if (entered.trim() != otp.otp) return OtpVerifyResult.wrongOtp;

    otp.markUsed();
    _parcelStatus = ParcelStatus.delivered;
    return OtpVerifyResult.success;
  }

  // ─── Accessors (for UI countdown timer) ──────────────────────────────────

  DateTime? get pickupOtpExpiresAt => _pickupOtp?.expiresAt;
  DateTime? get deliveryOtpExpiresAt => _deliveryOtp?.expiresAt;
}
