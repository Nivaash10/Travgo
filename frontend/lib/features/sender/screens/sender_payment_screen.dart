import 'package:flutter/material.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_payment.dart';
import 'sender_payment_result_screen.dart';

/// Screen allowing Senders to select a payment method and complete payment for a booking/request.
class SenderPaymentScreen extends StatefulWidget {
  final SenderBooking? booking;
  final SenderDeliveryRequest? request;
  final double? priceRupees;
  final Function(SenderPayment)? onPaymentCompleted;
  final Duration delayDuration;

  const SenderPaymentScreen({
    super.key,
    this.booking,
    this.request,
    this.priceRupees,
    this.onPaymentCompleted,
    this.delayDuration = const Duration(milliseconds: 800),
  });

  @override
  State<SenderPaymentScreen> createState() => _SenderPaymentScreenState();
}

class _SenderPaymentScreenState extends State<SenderPaymentScreen> {
  String _selectedPaymentMethod = 'UPI';
  bool _isProcessing = false;

  final double _platformFee = 15.0;

  double get _basePrice {
    if (widget.priceRupees != null) return widget.priceRupees!;
    if (widget.booking != null) return widget.booking!.deliveryPrice;
    if (widget.request != null) return widget.request!.traveller.priceRupees;
    return 100.0;
  }

  double get _totalAmount => _basePrice + _platformFee;

  String get _bookingId =>
      widget.booking?.id ??
      'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  String get _requestId =>
      widget.request != null ? 'REQ-101' : (widget.booking?.id ?? 'REQ-101');

  String get _travellerName =>
      widget.booking?.travellerName ??
      widget.booking?.request.traveller.travellerName ??
      widget.request?.traveller.travellerName ??
      'Arun';

  String get _route =>
      widget.booking?.request.traveller.route ??
      widget.request?.traveller.route ??
      'Coimbatore → Chennai';

  String get _travelDateTime =>
      widget.booking?.request.traveller.travelDateTime ??
      widget.request?.traveller.travelDateTime ??
      'Today • 8:30 AM';

  double get _parcelWeight =>
      widget.booking?.request.parcelWeightKg ??
      widget.request?.parcelWeightKg ??
      2.0;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    if (widget.delayDuration > Duration.zero) {
      await Future.delayed(widget.delayDuration);
    }

    if (!mounted) return;

    final payment = SenderPayment(
      paymentId: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      bookingId: _bookingId,
      requestId: _requestId,
      amountRupees: _totalAmount,
      paymentMethod: _selectedPaymentMethod,
      status: SenderPaymentStatus.paid,
      createdAt: DateTime.now(),
      paidAt: DateTime.now(),
    );

    widget.onPaymentCompleted?.call(payment);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SenderPaymentResultScreen(
          payment: payment,
          travellerName: _travellerName,
          route: _route,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: _isProcessing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Processing Payment...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please do not close or refresh the screen.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      'Complete Your Payment',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Demo Escrow Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Demo Escrow Protection Enabled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                                Text(
                                  'Funds are securely held in escrow and only released to traveller upon Delivery OTP verification.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Booking Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BOOKING SUMMARY',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Divider(height: 20),
                            _SummaryLine(label: 'Booking ID', value: _bookingId),
                            _SummaryLine(label: 'Traveller', value: _travellerName),
                            if (widget.request?.receiver != null)
                              _SummaryLine(label: 'Receiver', value: widget.request!.receiver!.fullName),
                            _SummaryLine(label: 'Route', value: _route),
                            _SummaryLine(label: 'Travel Date', value: _travelDateTime),
                            _SummaryLine(
                                label: 'Parcel Weight', value: '$_parcelWeight kg'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Method Section
                    Text(
                      'Select Payment Method',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _PaymentMethodTile(
                      title: 'UPI (GPay / PhonePe / Paytm)',
                      subtitle: 'Instant transfer via UPI ID or QR',
                      icon: Icons.account_balance_wallet_outlined,
                      value: 'UPI',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (val) {
                        setState(() {
                          _selectedPaymentMethod = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    _PaymentMethodTile(
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, RuPay',
                      icon: Icons.credit_card_outlined,
                      value: 'Credit Card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (val) {
                        setState(() {
                          _selectedPaymentMethod = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    _PaymentMethodTile(
                      title: 'Net Banking',
                      subtitle: 'All major Indian banks supported',
                      icon: Icons.account_balance_outlined,
                      value: 'Net Banking',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (val) {
                        setState(() {
                          _selectedPaymentMethod = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    _PaymentMethodTile(
                      title: 'Cash / Pay at Pickup',
                      subtitle: 'Pay directly to traveller during pickup',
                      icon: Icons.payments_outlined,
                      value: 'Pay at Pickup',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (val) {
                        setState(() {
                          _selectedPaymentMethod = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Price Breakdown Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Price',
                                    style: TextStyle(color: Colors.grey[700])),
                                Text('₹${_basePrice.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Platform Fee (Mock)',
                                    style: TextStyle(color: Colors.grey[700])),
                                Text('₹${_platformFee.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${_totalAmount.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pay Button
                    ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Pay ₹${_totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : Colors.grey[700],
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? theme.colorScheme.primary : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
