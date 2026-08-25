/// OTP Model — Phase 1
///
/// Contains data structures for OTP verification.
/// No UI logic lives here.
///
/// NOTE (Phase 1): OTP verification is performed locally with mock data.
/// In production this will be replaced by backend API calls in OtpService.
library;

enum OtpType { pickup, delivery }

/// Represents a single OTP instance tied to a parcel.
class OtpModel {
  final String parcelId;
  final OtpType otpType;
  final String otp;
  final DateTime expiresAt;
  bool isUsed;

  OtpModel({
    required this.parcelId,
    required this.otpType,
    required this.otp,
    required this.expiresAt,
    this.isUsed = false,
  });

  /// Returns true when the current time is past [expiresAt].
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// An OTP is valid only when it has NOT expired AND has NOT been used.
  bool get isValid => !isExpired && !isUsed;

  /// Mark this OTP as consumed so it cannot be reused.
  void markUsed() {
    isUsed = true;
  }

  @override
  String toString() =>
      'OtpModel(parcelId: $parcelId, type: $otpType, used: $isUsed, expired: $isExpired)';
}
