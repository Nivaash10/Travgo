import 'package:flutter/material.dart';

enum PaymentType {
  upi,
  card,
  netBanking,
  travgoWallet,
  cashOnPickup,
}

enum OrderLifecycleStep {
  booking(
    title: 'Booking Confirmed',
    subtitle: 'Order created and assigned to traveller',
    icon: Icons.assignment_turned_in_outlined,
    stageIndex: 0,
  ),
  payment(
    title: 'Payment Received',
    subtitle: 'Funds securely locked in Travgo Escrow',
    icon: Icons.account_balance_wallet_outlined,
    stageIndex: 1,
  ),
  confirmation(
    title: 'Traveller Acceptance',
    subtitle: 'Traveller accepted package delivery terms',
    icon: Icons.check_circle_outline,
    stageIndex: 2,
  ),
  pickup(
    title: 'Package Picked Up',
    subtitle: 'Package collected from sender with pickup OTP',
    icon: Icons.local_shipping_outlined,
    stageIndex: 3,
  ),
  inTransit(
    title: 'In Transit',
    subtitle: 'Traveller is en route to destination city',
    icon: Icons.flight_takeoff_outlined,
    stageIndex: 4,
  ),
  delivery(
    title: 'Delivered to Recipient',
    subtitle: 'Delivery confirmed via secure delivery OTP',
    icon: Icons.inventory_2_outlined,
    stageIndex: 5,
  ),
  payout(
    title: 'Payout Released',
    subtitle: 'Escrow unlocked and credited to Traveller account',
    icon: Icons.payments_outlined,
    stageIndex: 6,
  );

  const OrderLifecycleStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stageIndex,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int stageIndex;
}

class BookingDetails {
  final String bookingId;
  final String senderName;
  final String recipientName;
  final String travellerName;
  final String travellerRating;
  final String pickupCity;
  final String dropCity;
  final String packageCategory;
  final double packageWeightKg;
  final String estimatedDelivery;
  final DateTime createdAt;

  const BookingDetails({
    required this.bookingId,
    required this.senderName,
    required this.recipientName,
    required this.travellerName,
    required this.travellerRating,
    required this.pickupCity,
    required this.dropCity,
    required this.packageCategory,
    required this.packageWeightKg,
    required this.estimatedDelivery,
    required this.createdAt,
  });
}

class PriceBreakdown {
  final double baseDeliveryFee;
  final double itemInsuranceFee;
  final double platformFee;
  final double taxes;
  final double discountAmount;
  final String? appliedCoupon;

  const PriceBreakdown({
    required this.baseDeliveryFee,
    required this.itemInsuranceFee,
    required this.platformFee,
    required this.taxes,
    this.discountAmount = 0.0,
    this.appliedCoupon,
  });

  double get subtotal => baseDeliveryFee + itemInsuranceFee + platformFee;
  double get total => (subtotal + taxes - discountAmount).clamp(0.0, double.infinity);

  PriceBreakdown copyWith({
    double? baseDeliveryFee,
    double? itemInsuranceFee,
    double? platformFee,
    double? taxes,
    double? discountAmount,
    String? appliedCoupon,
    bool clearCoupon = false,
  }) {
    return PriceBreakdown(
      baseDeliveryFee: baseDeliveryFee ?? this.baseDeliveryFee,
      itemInsuranceFee: itemInsuranceFee ?? this.itemInsuranceFee,
      platformFee: platformFee ?? this.platformFee,
      taxes: taxes ?? this.taxes,
      discountAmount: clearCoupon ? 0.0 : (discountAmount ?? this.discountAmount),
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
    );
  }
}

class PaymentTransaction {
  final String transactionId;
  final String bookingId;
  final double amount;
  final PaymentType paymentType;
  final String paymentMethodLabel;
  final String? upiIdOrMaskedCard;
  final DateTime timestamp;
  final String status;
  final bool isEscrowLocked;

  const PaymentTransaction({
    required this.transactionId,
    required this.bookingId,
    required this.amount,
    required this.paymentType,
    required this.paymentMethodLabel,
    this.upiIdOrMaskedCard,
    required this.timestamp,
    required this.status,
    required this.isEscrowLocked,
  });
}

class TravellerPayoutInfo {
  final String payoutId;
  final String bookingId;
  final String travellerName;
  final double baseFare;
  final double speedBonus;
  final double tipAmount;
  final double platformCommission;
  final String payoutDestination; // e.g. "HDFC Bank •••• 5829" or "rahul@oksbi"
  final String settlementStatus; // "Escrow Held", "Processing", "Settled"
  final DateTime? settledAt;

  const TravellerPayoutInfo({
    required this.payoutId,
    required this.bookingId,
    required this.travellerName,
    required this.baseFare,
    required this.speedBonus,
    required this.tipAmount,
    required this.platformCommission,
    required this.payoutDestination,
    required this.settlementStatus,
    this.settledAt,
  });

  double get grossEarnings => baseFare + speedBonus + tipAmount;
  double get netPayout => grossEarnings - platformCommission;

  TravellerPayoutInfo copyWith({
    String? settlementStatus,
    DateTime? settledAt,
  }) {
    return TravellerPayoutInfo(
      payoutId: payoutId,
      bookingId: bookingId,
      travellerName: travellerName,
      baseFare: baseFare,
      speedBonus: speedBonus,
      tipAmount: tipAmount,
      platformCommission: platformCommission,
      payoutDestination: payoutDestination,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}
