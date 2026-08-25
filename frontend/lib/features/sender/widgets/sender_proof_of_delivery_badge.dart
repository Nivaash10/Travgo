import 'package:flutter/material.dart';

/// Available states for proof of delivery badge.
enum ProofOfDeliveryState {
  available,
  pending,
  confirmed,
}

/// Reusable badge widget for displaying Proof of Delivery availability and confirmation status.
class SenderProofOfDeliveryBadge extends StatelessWidget {
  final ProofOfDeliveryState state;

  const SenderProofOfDeliveryBadge({
    super.key,
    required this.state,
  });

  String _getText() {
    switch (state) {
      case ProofOfDeliveryState.available:
        return 'Proof Available';
      case ProofOfDeliveryState.pending:
        return 'Proof Pending';
      case ProofOfDeliveryState.confirmed:
        return 'Delivery Confirmed';
    }
  }

  IconData _getIcon() {
    switch (state) {
      case ProofOfDeliveryState.available:
        return Icons.verified_user_outlined;
      case ProofOfDeliveryState.pending:
        return Icons.schedule;
      case ProofOfDeliveryState.confirmed:
        return Icons.task_alt;
    }
  }

  Color _getColor() {
    switch (state) {
      case ProofOfDeliveryState.available:
        return Colors.green[700]!;
      case ProofOfDeliveryState.pending:
        return Colors.orange[800]!;
      case ProofOfDeliveryState.confirmed:
        return Colors.blue[700]!;
    }
  }

  Color _getBackgroundColor() {
    switch (state) {
      case ProofOfDeliveryState.available:
        return Colors.green[50]!;
      case ProofOfDeliveryState.pending:
        return Colors.orange[50]!;
      case ProofOfDeliveryState.confirmed:
        return Colors.blue[50]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final bgColor = _getBackgroundColor();

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
          Icon(_getIcon(), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getText(),
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
