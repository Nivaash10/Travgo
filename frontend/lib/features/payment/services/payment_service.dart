import 'package:flutter/foundation.dart';
import '../models/payment_models.dart';

class PaymentService extends ChangeNotifier {
  // Singleton pattern for simple global demo state management
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;

  PaymentService._internal() {
    _initializeDefaultData();
  }

  late BookingDetails _currentBooking;
  late PriceBreakdown _priceBreakdown;
  PaymentTransaction? _currentTransaction;
  late OrderLifecycleStep _currentStep;
  late TravellerPayoutInfo _travellerPayout;
  double _walletBalance = 2450.0;

  // Getters
  BookingDetails get currentBooking => _currentBooking;
  PriceBreakdown get priceBreakdown => _priceBreakdown;
  PaymentTransaction? get currentTransaction => _currentTransaction;
  OrderLifecycleStep get currentStep => _currentStep;
  TravellerPayoutInfo get travellerPayout => _travellerPayout;
  double get walletBalance => _walletBalance;

  void _initializeDefaultData() {
    _currentBooking = BookingDetails(
      bookingId: 'TG-${DateTime.now().year % 100}9482',
      senderName: 'Aarav Sharma',
      recipientName: 'Pooja Verma',
      travellerName: 'Rohan Mehta',
      travellerRating: '4.9 ⭐ (128 trips)',
      pickupCity: 'Bengaluru (Koramangala)',
      dropCity: 'Mumbai (Bandra West)',
      packageCategory: 'Electronics / Documents',
      packageWeightKg: 1.5,
      estimatedDelivery: 'Tomorrow, 4:00 PM',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    );

    _priceBreakdown = const PriceBreakdown(
      baseDeliveryFee: 420.0,
      itemInsuranceFee: 50.0,
      platformFee: 29.0,
      taxes: 18.0,
      discountAmount: 0.0,
    );

    _currentStep = OrderLifecycleStep.payment;

    _travellerPayout = TravellerPayoutInfo(
      payoutId: 'PO-TRV-8821',
      bookingId: _currentBooking.bookingId,
      travellerName: _currentBooking.travellerName,
      baseFare: 420.0,
      speedBonus: 50.0,
      tipAmount: 30.0,
      platformCommission: 45.0,
      payoutDestination: 'HDFC Bank •••• 4821 (IFSC: HDFC0001289)',
      settlementStatus: 'Escrow Locked',
      settledAt: null,
    );
  }

  // Coupon application logic (supports SIH2026, TRAVGO50, FIRSTTRIP)
  String? applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return 'Please enter a coupon code';

    if (cleanCode == 'SIH2026') {
      _priceBreakdown = _priceBreakdown.copyWith(
        discountAmount: 100.0,
        appliedCoupon: 'SIH2026 (-₹100 SIH Special)',
      );
      notifyListeners();
      return null;
    } else if (cleanCode == 'TRAVGO50') {
      _priceBreakdown = _priceBreakdown.copyWith(
        discountAmount: 50.0,
        appliedCoupon: 'TRAVGO50 (-₹50 Flat Off)',
      );
      notifyListeners();
      return null;
    } else if (cleanCode == 'FIRSTTRIP') {
      _priceBreakdown = _priceBreakdown.copyWith(
        discountAmount: 75.0,
        appliedCoupon: 'FIRSTTRIP (-₹75 Welcome Bonus)',
      );
      notifyListeners();
      return null;
    } else {
      return 'Invalid or expired coupon code';
    }
  }

  void removeCoupon() {
    _priceBreakdown = _priceBreakdown.copyWith(clearCoupon: true);
    notifyListeners();
  }

  // Simulate local payment processing
  Future<PaymentTransaction> processPayment({
    required PaymentType type,
    required String methodLabel,
    String? accountIdentifier,
  }) async {
    // Realistic prototype latency
    await Future.delayed(const Duration(milliseconds: 1400));

    final txId = 'TXN-TG${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    if (type == PaymentType.travgoWallet) {
      if (_walletBalance >= _priceBreakdown.total) {
        _walletBalance -= _priceBreakdown.total;
      }
    }

    _currentTransaction = PaymentTransaction(
      transactionId: txId,
      bookingId: _currentBooking.bookingId,
      amount: _priceBreakdown.total,
      paymentType: type,
      paymentMethodLabel: methodLabel,
      upiIdOrMaskedCard: accountIdentifier ?? (type == PaymentType.upi ? 'user@upi' : '•••• 4242'),
      timestamp: DateTime.now(),
      status: 'Escrow Secured',
      isEscrowLocked: true,
    );

    _currentStep = OrderLifecycleStep.confirmation;
    notifyListeners();
    return _currentTransaction!;
  }

  // Interactive step forward (SIH Demo control)
  void advanceStep() {
    final nextIndex = _currentStep.stageIndex + 1;
    if (nextIndex < OrderLifecycleStep.values.length) {
      _currentStep = OrderLifecycleStep.values[nextIndex];

      // Update payout state as step advances
      if (_currentStep == OrderLifecycleStep.delivery) {
        _travellerPayout = _travellerPayout.copyWith(
          settlementStatus: 'Ready for Release',
        );
      } else if (_currentStep == OrderLifecycleStep.payout) {
        _travellerPayout = _travellerPayout.copyWith(
          settlementStatus: 'Settled',
          settledAt: DateTime.now(),
        );
      }

      notifyListeners();
    }
  }

  // Interactive step backward or set step directly
  void setStep(OrderLifecycleStep step) {
    _currentStep = step;
    if (step == OrderLifecycleStep.payout) {
      _travellerPayout = _travellerPayout.copyWith(
        settlementStatus: 'Settled',
        settledAt: DateTime.now(),
      );
    } else if (step == OrderLifecycleStep.delivery) {
      _travellerPayout = _travellerPayout.copyWith(
        settlementStatus: 'Ready for Release',
      );
    } else {
      _travellerPayout = _travellerPayout.copyWith(
        settlementStatus: 'Escrow Locked',
      );
    }
    notifyListeners();
  }

  // Release traveller payout simulation
  Future<void> releaseTravellerPayout() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _travellerPayout = _travellerPayout.copyWith(
      settlementStatus: 'Settled',
      settledAt: DateTime.now(),
    );
    _currentStep = OrderLifecycleStep.payout;
    notifyListeners();
  }

  // Reset demo to initial state
  void resetDemo() {
    _initializeDefaultData();
    _currentTransaction = null;
    notifyListeners();
  }
}
