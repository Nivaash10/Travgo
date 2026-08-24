import 'package:flutter/material.dart';
import 'payment_colors.dart';
import 'payment_screen.dart';
import 'payment_confirmation_screen.dart';
import 'payment_status_screen.dart';
import 'traveller_payout_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../ratings/screens/rating_screen.dart';

/// Person 5 — Payment Module Hub (mobile)

class PaymentDemoHubScreen extends StatelessWidget {
  const PaymentDemoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Secure payment, held until delivery is verified.',
              style: TextStyle(fontSize: 13, color: kMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _statCard('₹120', 'Last payment')),
                const SizedBox(width: 10),
                Expanded(child: _statCard('4', 'Deliveries')),
                const SizedBox(width: 10),
                Expanded(child: _statCard('4.8★', 'Rating')),
              ],
            ),
            const SizedBox(height: 28),
            const Text('MODULE SCREENS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kMuted, letterSpacing: 0.8)),
            const SizedBox(height: 12),
            _menuTile(
              context,
              icon: Icons.credit_card,
              iconBg: const Color(0xFFEEF2FF),
              iconColor: kAccent,
              title: 'Checkout',
              subtitle: 'Pay for a booked parcel',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.check_circle_outline,
              iconBg: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF059669),
              title: 'Payment confirmation',
              subtitle: 'Receipt after a successful payment',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentConfirmationScreen(
                    amount: 120,
                    route: 'Coimbatore → Chennai',
                    method: 'UPI',
                  ),
                ),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.timeline_outlined,
              iconBg: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFD97706),
              title: 'Parcel status',
              subtitle: 'Booking → payment → pickup → delivery',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentStatusScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.account_balance_wallet_outlined,
              iconBg: const Color(0xFFF5F3FF),
              iconColor: const Color(0xFF7C3AED),
              title: 'Traveller payout',
              subtitle: 'Earnings breakdown and settlement status',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TravellerPayoutScreen()),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.star_outline_rounded,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              title: 'Rate a traveller',
              subtitle: 'Share your delivery experience',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RatingScreen(
                    parcelId: 'PCL-2026-0417',
                    travellerId: 'TRV-1042',
                    travellerName: 'Arun Kumar',
                  ),
                ),
              ),
            ),
            _menuTile(
              context,
              icon: Icons.notifications_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              title: 'Notifications',
              subtitle: 'Booking, payment and delivery alerts',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: kMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: kMuted),
            ],
          ),
        ),
      ),
    );
  }
}