import 'package:flutter/material.dart';
import '../models/sender_tracking.dart';

/// Reusable badge widget for displaying a SenderTrackingStatus.
class SenderTrackingStatusBadge extends StatelessWidget {
  final SenderTrackingStatus status;

  const SenderTrackingStatusBadge({
    super.key,
    required this.status,
  });

  String _getStatusText(SenderTrackingStatus status) {
    switch (status) {
      case SenderTrackingStatus.pending:
        return 'Pending';
      case SenderTrackingStatus.accepted:
        return 'Accepted';
      case SenderTrackingStatus.pickupPending:
        return 'Pickup Pending';
      case SenderTrackingStatus.pickedUp:
        return 'Picked Up';
      case SenderTrackingStatus.inTransit:
        return 'In Transit';
      case SenderTrackingStatus.arrived:
        return 'Arrived';
      case SenderTrackingStatus.delivered:
        return 'Delivered';
      case SenderTrackingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(SenderTrackingStatus status) {
    switch (status) {
      case SenderTrackingStatus.pending:
        return Icons.receipt_long_outlined;
      case SenderTrackingStatus.accepted:
        return Icons.check_circle_outline;
      case SenderTrackingStatus.pickupPending:
        return Icons.schedule;
      case SenderTrackingStatus.pickedUp:
        return Icons.inventory_2_outlined;
      case SenderTrackingStatus.inTransit:
        return Icons.local_shipping_outlined;
      case SenderTrackingStatus.arrived:
        return Icons.location_on_outlined;
      case SenderTrackingStatus.delivered:
        return Icons.verified_outlined;
      case SenderTrackingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color _getStatusColor(SenderTrackingStatus status) {
    switch (status) {
      case SenderTrackingStatus.pending:
      case SenderTrackingStatus.pickupPending:
        return Colors.orange[800]!;
      case SenderTrackingStatus.accepted:
        return Colors.blue[700]!;
      case SenderTrackingStatus.pickedUp:
        return Colors.deepOrange[700]!;
      case SenderTrackingStatus.inTransit:
        return Colors.blue[800]!;
      case SenderTrackingStatus.arrived:
        return Colors.teal[700]!;
      case SenderTrackingStatus.delivered:
        return Colors.green[700]!;
      case SenderTrackingStatus.cancelled:
        return Colors.red[700]!;
    }
  }

  Color _getBackgroundColor(SenderTrackingStatus status) {
    switch (status) {
      case SenderTrackingStatus.pending:
      case SenderTrackingStatus.pickupPending:
        return Colors.orange[50]!;
      case SenderTrackingStatus.accepted:
        return Colors.blue[50]!;
      case SenderTrackingStatus.pickedUp:
        return Colors.deepOrange[50]!;
      case SenderTrackingStatus.inTransit:
        return Colors.blue[50]!;
      case SenderTrackingStatus.arrived:
        return Colors.teal[50]!;
      case SenderTrackingStatus.delivered:
        return Colors.green[50]!;
      case SenderTrackingStatus.cancelled:
        return Colors.red[50]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final bgColor = _getBackgroundColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
