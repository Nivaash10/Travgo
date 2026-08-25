import 'package:flutter/material.dart';
import '../models/sender_delivery_completion.dart';
import '../widgets/sender_proof_of_delivery_badge.dart';

/// Screen allowing Senders to view digital proof of delivery for a completed booking.
///
/// Note: Frontend-only presentation view. Official backend image/signature assets will be provided by Person 1.
class SenderProofViewerScreen extends StatelessWidget {
  final SenderDeliveryCompletion completion;

  const SenderProofViewerScreen({
    super.key,
    required this.completion,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final minuteStr = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} â€¢ ${date.hour}:$minuteStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proof of Delivery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROOF OF DELIVERY',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SenderProofOfDeliveryBadge(
                            state: ProofOfDeliveryState.available,
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _RowItem(label: 'Booking ID', value: completion.bookingId),
                      _RowItem(
                        label: 'Delivered To',
                        value: completion.receiverName ?? 'Recipient',
                      ),
                      _RowItem(
                        label: 'Delivered At',
                        value: _formatDate(completion.deliveredAt),
                      ),
                      _RowItem(
                        label: 'Proof Type',
                        value: completion.proofType ?? 'Digital Signature',
                      ),
                      _RowItem(
                        label: 'Proof Reference',
                        value: completion.proofReference ?? 'POD-${completion.bookingId}-101',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mock Digital Signature / Receipt Representation Card
              Text(
                'Digital Receipt & Signature',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 56,
                      color: Colors.green[600],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'VERIFIED HANDOVER',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'OTP Handover Code Confirmed',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(height: 32),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child: Text(
                          'Signature: ${completion.receiverName ?? "S. Kumar"} âœ“',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '(Demo proof of delivery document)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Back Button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close Proof Viewer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({
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
