import 'package:flutter/material.dart';
import '../models/sender_payment.dart';

/// Reusable badge widget for displaying a SenderPaymentStatus.
class SenderPaymentStatusBadge extends StatelessWidget {
  final SenderPaymentStatus status;

  const SenderPaymentStatusBadge({
    super.key,
    required this.status,
  });

  String _getStatusText(SenderPaymentStatus status) {
    switch (status) {
      case SenderPaymentStatus.pending:
        return 'Payment Pending';
      case SenderPaymentStatus.processing:
        return 'Processing';
      case SenderPaymentStatus.paid:
        return 'Paid';
      case SenderPaymentStatus.failed:
        return 'Payment Failed';
      case SenderPaymentStatus.cancelled:
        return 'Cancelled';
      case SenderPaymentStatus.refunded:
        return 'Refunded';
    }
  }

  IconData _getStatusIcon(SenderPaymentStatus status) {
    switch (status) {
      case SenderPaymentStatus.pending:
        return Icons.access_time_outlined;
      case SenderPaymentStatus.processing:
        return Icons.sync;
      case SenderPaymentStatus.paid:
        return Icons.check_circle_outline;
      case SenderPaymentStatus.failed:
        return Icons.error_outline;
      case SenderPaymentStatus.cancelled:
        return Icons.cancel_outlined;
      case SenderPaymentStatus.refunded:
        return Icons.currency_exchange;
    }
  }

  Color _getStatusColor(SenderPaymentStatus status) {
    switch (status) {
      case SenderPaymentStatus.pending:
        return Colors.orange[800]!;
      case SenderPaymentStatus.processing:
        return Colors.blue[700]!;
      case SenderPaymentStatus.paid:
        return Colors.green[700]!;
      case SenderPaymentStatus.failed:
        return Colors.red[700]!;
      case SenderPaymentStatus.cancelled:
        return Colors.grey[700]!;
      case SenderPaymentStatus.refunded:
        return Colors.purple[700]!;
    }
  }

  Color _getBackgroundColor(SenderPaymentStatus status) {
    switch (status) {
      case SenderPaymentStatus.pending:
        return Colors.orange[50]!;
      case SenderPaymentStatus.processing:
        return Colors.blue[50]!;
      case SenderPaymentStatus.paid:
        return Colors.green[50]!;
      case SenderPaymentStatus.failed:
        return Colors.red[50]!;
      case SenderPaymentStatus.cancelled:
        return Colors.grey[100]!;
      case SenderPaymentStatus.refunded:
        return Colors.purple[50]!;
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
