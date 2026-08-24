import 'package:flutter/material.dart';
import 'payment_colors.dart';

/// Person 5 — Traveller Payout Status, mobile layout

class TravellerPayoutScreen extends StatelessWidget {
  final String parcelId;
  final double fare;
  final double platformFee;
  final String status;

  const TravellerPayoutScreen({
    super.key,
    this.parcelId = 'PCL-2026-0417',
    this.fare = 100,
    this.platformFee = 20,
    this.status = 'Pending',
  });

  double get netPayout => fare - platformFee;

  @override
  Widget build(BuildContext context) {
    final settled = status == 'Settled';
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Payout', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(parcelId, style: const TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: settled ? const Color(0xFFEEF2FF) : Colors.white,
                border: Border.all(color: settled ? kAccent : kBorder),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: settled ? kAccent : kMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('₹${netPayout.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kText)),
            Text(settled ? 'Paid out to your account' : 'Will be released after delivery is confirmed',
                style: const TextStyle(fontSize: 13, color: kMuted)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _row('Delivery fare', '₹${fare.toStringAsFixed(0)}'),
                  const SizedBox(height: 10),
                  _row('Platform fee', '- ₹${platformFee.toStringAsFixed(0)}'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: kBorder)),
                  _row('Net payout', '₹${netPayout.toStringAsFixed(0)}', bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? kText : kMuted,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}