import 'package:flutter/material.dart';
import '../models/traveler_trip.dart';

class TripCard extends StatelessWidget {
  final TravelerTrip trip;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return successColor;
      case 'COMPLETED':
        return primaryColor;
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return subtitleColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(trip.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status Badge & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trip.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (trip.isNegotiable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Negotiable',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '₹${trip.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Route: Source -> Destination
            Row(
              children: [
                const Icon(Icons.trip_origin_rounded, color: primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.source,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, color: subtitleColor, size: 16),
                ),
                const Icon(Icons.place_rounded, color: secondaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),

            // Bottom Row: Date/Time & Available Capacity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: subtitleColor),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(trip.travelDate)} • ${trip.travelTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.scale_rounded, size: 14, color: subtitleColor),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.availableWeight} kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: subtitleColor,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
