import 'package:flutter/material.dart';
import '../models/payment_models.dart';

class PayoutSummaryCard extends StatelessWidget {
  final TravellerPayoutInfo payout;
  final VoidCallback? onInstantWithdraw;
  final bool isProcessing;

  const PayoutSummaryCard({
    super.key,
    required this.payout,
    this.onInstantWithdraw,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isSettled = payout.settlementStatus == 'Settled';
    final isReady = payout.settlementStatus == 'Ready for Release';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Earnings Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSettled
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : (isReady
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSettled
                          ? Icons.check_circle
                          : (isReady ? Icons.bolt : Icons.lock_clock),
                      size: 14,
                      color: isSettled
                          ? const Color(0xFF059669)
                          : (isReady ? const Color(0xFF2563EB) : const Color(0xFFD97706)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payout.settlementStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSettled
                            ? const Color(0xFF059669)
                            : (isReady ? const Color(0xFF2563EB) : const Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Net payout hero display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  'Net Traveller Payout',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.indigo.shade200 : const Color(0xFF4338CA),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${payout.netPayout.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF3730A3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSettled
                      ? 'Credited to account on ${payout.settledAt?.hour ?? 12}:${payout.settledAt?.minute.toString().padLeft(2, '0') ?? '00'}'
                      : (isReady
                          ? 'Package delivered! Payout ready for release'
                          : 'Funds secured in Escrow. Released on Delivery OTP'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.indigo.shade200 : const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payout items breakdown
          _buildItemRow('Base Trip Delivery Fee', '₹${payout.baseFare.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildItemRow('Express Speed Bonus', '₹${payout.speedBonus.toStringAsFixed(0)}', isBonus: true),
          const SizedBox(height: 8),
          _buildItemRow('Sender Gratitude Tip', '₹${payout.tipAmount.toStringAsFixed(0)}', isBonus: true),
          const SizedBox(height: 8),
          _buildItemRow(
            'Travgo Platform Cut (10%)',
            '-₹${payout.platformCommission.toStringAsFixed(0)}',
            isDeduction: true,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Bank account destination
          Row(
            children: [
              const Icon(Icons.account_balance, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payout Account',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      payout.payoutDestination,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, size: 16, color: Color(0xFF10B981)),
            ],
          ),

          // Action button if not settled
          if (!isSettled && onInstantWithdraw != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onInstantWithdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  isProcessing ? 'Processing Transfer...' : 'Simulate Instant Settlement',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
    String label,
    String amount, {
    bool isBonus = false,
    bool isDeduction = false,
  }) {
    Color amountColor = Colors.grey.shade800;
    if (isBonus) amountColor = const Color(0xFF059669);
    if (isDeduction) amountColor = const Color(0xFFDC2626);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
