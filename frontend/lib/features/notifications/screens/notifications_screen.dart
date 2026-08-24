import 'package:flutter/material.dart';
import 'notification_colors.dart';
import '../models/notification_models.dart';

/// Person 5 — Notifications list, mobile layout.
/// Seeded with dummy data reflecting the TRAVGO parcel lifecycle
/// (Section 13/22 of the spec) so it's not empty in a demo.

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    AppNotification(
      type: NotificationType.payout,
      title: 'Payout settled',
      subtitle: '₹100 credited to your account for PCL-2026-0417',
      time: '2m ago',
    ),
    AppNotification(
      type: NotificationType.rating,
      title: 'Rate your traveller',
      subtitle: 'Arun Kumar delivered your parcel. Share your experience.',
      time: '10m ago',
    ),
    AppNotification(
      type: NotificationType.delivered,
      title: 'Parcel delivered',
      subtitle: 'Delivery OTP verified for PCL-2026-0417',
      time: '12m ago',
    ),
    AppNotification(
      type: NotificationType.transit,
      title: 'Parcel in transit',
      subtitle: 'Arun Kumar is en route to Chennai',
      time: '3h ago',
      read: true,
    ),
    AppNotification(
      type: NotificationType.pickup,
      title: 'Parcel picked up',
      subtitle: 'Pickup OTP verified in Coimbatore',
      time: '5h ago',
      read: true,
    ),
    AppNotification(
      type: NotificationType.payment,
      title: 'Payment confirmed',
      subtitle: '₹120 paid via UPI, held securely',
      time: '6h ago',
      read: true,
    ),
    AppNotification(
      type: NotificationType.booking,
      title: 'Request accepted',
      subtitle: 'Arun Kumar accepted your Coimbatore → Chennai request',
      time: '1d ago',
      read: true,
    ),
  ];

  IconData _iconFor(NotificationType t) {
    switch (t) {
      case NotificationType.booking:
        return Icons.handshake_outlined;
      case NotificationType.payment:
        return Icons.credit_card;
      case NotificationType.pickup:
        return Icons.inventory_2_outlined;
      case NotificationType.transit:
        return Icons.local_shipping_outlined;
      case NotificationType.delivered:
        return Icons.check_circle_outline;
      case NotificationType.rating:
        return Icons.star_border_rounded;
      case NotificationType.payout:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _colorFor(NotificationType t) {
    switch (t) {
      case NotificationType.booking:
        return const Color(0xFF7C3AED);
      case NotificationType.payment:
        return kAccent;
      case NotificationType.pickup:
        return const Color(0xFFD97706);
      case NotificationType.transit:
        return const Color(0xFFD97706);
      case NotificationType.delivered:
        return const Color(0xFF059669);
      case NotificationType.rating:
        return kAccent;
      case NotificationType.payout:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _notifications.length,
          itemBuilder: (context, i) => _notificationTile(_notifications[i]),
        ),
      ),
    );
  }

  Widget _notificationTile(AppNotification n) {
    final color = _colorFor(n.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: n.read ? kBorder : color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(n.type), size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(n.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                            color: kText,
                          )),
                    ),
                    if (!n.read)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6, top: 2),
                        decoration: BoxDecoration(color: kAccent, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(n.subtitle, style: const TextStyle(fontSize: 12, color: kMuted)),
                const SizedBox(height: 4),
                Text(n.time, style: const TextStyle(fontSize: 11, color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}