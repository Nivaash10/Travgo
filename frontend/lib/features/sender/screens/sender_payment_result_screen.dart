import 'package:flutter/material.dart';
import '../models/sender_payment.dart';

/// Screen displaying the result of a Sender payment transaction (Success or Failure).
class SenderPaymentResultScreen extends StatelessWidget {
  final SenderPayment payment;
  final String? travellerName;
  final String? route;
  final String? errorMessage;
  final VoidCallback? onTryAgain;

  const SenderPaymentResultScreen({
    super.key,
    required this.payment,
    this.travellerName,
    this.route,
    this.errorMessage,
    this.onTryAgain,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = payment.status == SenderPaymentStatus.paid;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSuccess ? 'Payment Successful' : 'Payment Failed'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Status Icon
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                size: 80,
                color: isSuccess ? Colors.green[600] : Colors.red[600],
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isSuccess ? 'Payment Successful' : 'Payment Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                isSuccess
                    ? 'Your payment has been processed successfully.'
                    : (errorMessage ?? 'Transaction declined. Please try again.'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Transaction Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: 'Payment ID', value: payment.paymentId),
                      const SizedBox(height: 8),
                      _SummaryRow(
                          label: 'Booking ID', value: payment.bookingId),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: isSuccess ? 'Amount Paid' : 'Amount',
                        value: '₹${payment.amountRupees.toStringAsFixed(0)}',
                        isBoldValue: true,
                        valueColor: isSuccess
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                          label: 'Payment Method',
                          value: payment.paymentMethod),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Date & Time',
                        value: _formatDate(payment.paidAt ?? payment.createdAt),
                      ),
                      if (travellerName != null) ...[
                        const SizedBox(height: 8),
                        _SummaryRow(label: 'Traveller', value: travellerName!),
                      ],
                      if (route != null) ...[
                        const SizedBox(height: 8),
                        _SummaryRow(label: 'Route', value: route!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Actions
              if (isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Booking',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back to Sender Dashboard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onTryAgain ?? () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Try Again',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBoldValue = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
