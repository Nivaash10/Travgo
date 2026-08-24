import 'package:flutter/material.dart';
import 'payment_colors.dart';
import 'payment_confirmation_screen.dart';

/// Person 5 — Payment Screen (Checkout), mobile layout

class PaymentScreen extends StatefulWidget {
  final String parcelId;
  final String route;
  final double baseFare;
  final double serviceFee;
  final String travellerName;

  const PaymentScreen({
    super.key,
    this.parcelId = 'PCL-2026-0417',
    this.route = 'Coimbatore → Chennai',
    this.baseFare = 100,
    this.serviceFee = 20,
    this.travellerName = 'Arun Kumar',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'UPI';

  double get total => widget.baseFare + widget.serviceFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Parcel ${widget.parcelId}', style: const TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 4),
            Text(widget.route, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kText)),
            const SizedBox(height: 10),
            _trustBadge(),
            const SizedBox(height: 20),
            _summaryCard(),
            const SizedBox(height: 24),
            const Text('Payment method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
            const SizedBox(height: 8),
            _methodTile('UPI', Icons.qr_code),
            _methodTile('Card', Icons.credit_card),
            _methodTile('Wallet', Icons.account_balance_wallet_outlined),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentConfirmationScreen(
                        amount: total,
                        route: widget.route,
                        method: _method,
                      ),
                    ),
                  );
                },
                child: Text('Pay ₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your payment is held securely and released to the traveller only after delivery is verified.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 16, color: Color(0xFF059669)),
          const SizedBox(width: 6),
          Text(
            'Verified traveller · ${widget.travellerName}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _row('Delivery fare', '₹${widget.baseFare.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _row('Service fee', '₹${widget.serviceFee.toStringAsFixed(0)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: kBorder)),
          _row('Total', '₹${total.toStringAsFixed(0)}', bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? kText : kMuted,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  Widget _methodTile(String label, IconData icon) {
    final selected = _method == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _method = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: selected ? kAccent : kBorder, width: selected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? kAccent : kMuted),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: kText))),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? kAccent : kBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}