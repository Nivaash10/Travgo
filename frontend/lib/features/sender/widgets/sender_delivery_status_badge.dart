import 'package:flutter/material.dart';
import '../models/sender_delivery_status.dart';

/// Reusable status badge widget displaying delivery status with icon and label.
class SenderDeliveryStatusBadge extends StatelessWidget {
  final SenderDeliveryStatus status;

  const SenderDeliveryStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.textColor),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(SenderDeliveryStatus status) {
    switch (status) {
      case SenderDeliveryStatus.pending:
        return const _StatusConfig(
          label: 'Pending',
          icon: Icons.access_time_outlined,
          backgroundColor: Color(0xFFFFF3E0),
          borderColor: Color(0xFFFFB74D),
          textColor: Color(0xFFE65100),
        );
      case SenderDeliveryStatus.accepted:
        return const _StatusConfig(
          label: 'Accepted',
          icon: Icons.check_circle_outline,
          backgroundColor: Color(0xFFE3F2FD),
          borderColor: Color(0xFF64B5F6),
          textColor: Color(0xFF1565C0),
        );
      case SenderDeliveryStatus.rejected:
        return const _StatusConfig(
          label: 'Rejected',
          icon: Icons.cancel_outlined,
          backgroundColor: Color(0xFFFFEBEE),
          borderColor: Color(0xFFE57373),
          textColor: Color(0xFFC62828),
        );
      case SenderDeliveryStatus.pickupPending:
        return const _StatusConfig(
          label: 'Pickup Pending',
          icon: Icons.pin_drop_outlined,
          backgroundColor: Color(0xFFF3E5F5),
          borderColor: Color(0xFFBA68C8),
          textColor: Color(0xFF6A1B9A),
        );
      case SenderDeliveryStatus.pickedUp:
        return const _StatusConfig(
          label: 'Picked Up',
          icon: Icons.takeout_dining_outlined,
          backgroundColor: Color(0xFFE0F2F1),
          borderColor: Color(0xFF4DB6AC),
          textColor: Color(0xFF00695C),
        );
      case SenderDeliveryStatus.inTransit:
        return const _StatusConfig(
          label: 'In Transit',
          icon: Icons.local_shipping_outlined,
          backgroundColor: Color(0xFFE8EAF6),
          borderColor: Color(0xFF7986CB),
          textColor: Color(0xFF283593),
        );
      case SenderDeliveryStatus.delivered:
        return const _StatusConfig(
          label: 'Delivered',
          icon: Icons.task_alt_outlined,
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: Color(0xFF81C784),
          textColor: Color(0xFF2E7D32),
        );
      case SenderDeliveryStatus.cancelled:
        return const _StatusConfig(
          label: 'Cancelled',
          icon: Icons.block_outlined,
          backgroundColor: Color(0xFFFAFAFA),
          borderColor: Color(0xFFBDBDBD),
          textColor: Color(0xFF616161),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
