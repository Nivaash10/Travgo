import 'package:flutter/material.dart';

class EscrowBadge extends StatelessWidget {
  final bool compact;
  final String? customMessage;

  const EscrowBadge({
    super.key,
    this.compact = false,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0D9488).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 16,
              color: Color(0xFF0D9488),
            ),
            SizedBox(width: 6),
            Text(
              '100% Escrow Protected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D9488),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132A27) : const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0D9488).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 22,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Travgo Escrow Guarantee',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.lock_clock_outlined,
                      size: 14,
                      color: Color(0xFF0F766E),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customMessage ??
                      'Your money stays safe in Travgo Escrow. Funds are released to the traveller ONLY after you confirm safe parcel delivery via OTP.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? Colors.teal.shade100 : const Color(0xFF115E59),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
