import 'package:flutter/material.dart';
import 'payment_colors.dart';
import '../../ratings/screens/rating_screen.dart';
import 'traveller_payout_screen.dart';

/// Person 5 — Payment Status / Lifecycle Tracker, mobile layout
/// Matches TRAVGO parcel status state machine (Section 13):
/// REQUESTED → ACCEPTED → PAYMENT CONFIRMED → PICKED UP → IN TRANSIT → DELIVERED

class PaymentStatusScreen extends StatelessWidget {
  final String parcelId;
  final String route;
  final int currentStep;
  final String travellerId;
  final String travellerName;

  const PaymentStatusScreen({
    super.key,
    this.parcelId = 'PCL-2026-0417',
    this.route = 'Coimbatore → Chennai',
    this.currentStep = 2,
    this.travellerId = 'TRV-1042',
    this.travellerName = 'Arun Kumar',
  });

  static const _stages = [
    ('Booked', 'Request accepted by traveller'),
    ('Payment confirmed', 'Amount held securely'),
    ('Picked up', 'Pickup OTP verified'),
    ('In transit', 'Traveller en route'),
    ('Delivered', 'Delivery OTP verified'),
    ('Payout settled', 'Traveller paid out'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Parcel status', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parcelId, style: const TextStyle(color: kMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(route, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < _stages.length; i++) _stageTile(i),
            if (currentStep >= 4) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RatingScreen(
                          parcelId: parcelId,
                          travellerId: travellerId,
                          travellerName: travellerName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('Rate your traveller'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
            if (currentStep >= 5) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TravellerPayoutScreen(
                          parcelId: parcelId,
                          status: 'Settled',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                  label: const Text('View payout'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kAccent),
                    foregroundColor: kAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stageTile(int i) {
    final done = i <= currentStep;
    final isLast = i == _stages.length - 1;
    final (title, subtitle) = _stages[i];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? kAccent : Colors.white,
                  border: Border.all(color: done ? kAccent : kBorder, width: 1.5),
                ),
                child: done ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 1.5, color: done ? kAccent : kBorder)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: done ? kText : kMuted,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}