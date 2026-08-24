import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_models.dart';

class TransactionReceiptCard extends StatelessWidget {
  final PaymentTransaction transaction;
  final BookingDetails booking;

  const TransactionReceiptCard({
    super.key,
    required this.transaction,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Receipt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ESCROW SECURED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Amount Display
                Text(
                  '₹${transaction.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Transferred to Travgo Escrow Vault',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Perforated Divider
                Row(
                  children: List.generate(
                    24,
                    (i) => Expanded(
                      child: Container(
                        height: 1.5,
                        color: i % 2 == 0
                            ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Key metadata details
                _buildReceiptRow(
                  context,
                  label: 'Transaction ID',
                  value: transaction.transactionId,
                  isCopyable: true,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  context,
                  label: 'Booking ID',
                  value: transaction.bookingId,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  context,
                  label: 'Payment Method',
                  value: '${transaction.paymentMethodLabel} (${transaction.upiIdOrMaskedCard ?? 'Verified'})',
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  context,
                  label: 'Sender → Recipient',
                  value: '${booking.senderName} → ${booking.recipientName}',
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  context,
                  label: 'Assigned Traveller',
                  value: booking.travellerName,
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  context,
                  label: 'Route',
                  value: '${booking.pickupCity} ➔ ${booking.dropCity}',
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  context,
                  label: 'Date & Time',
                  value: '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year}, ${transaction.timestamp.hour.toString().padLeft(2, '0')}:${transaction.timestamp.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isCopyable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction ID copied to clipboard!'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Icon(Icons.copy, size: 14, color: Colors.blue),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
