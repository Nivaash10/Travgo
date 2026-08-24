import 'package:flutter/material.dart';
import '../models/parcel_request.dart';

class RequestCard extends StatelessWidget {
  final ParcelRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onActiveDeliveryTap;

  const RequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onActiveDeliveryTap,
  });

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color cardColor = Color(0xFFFFFFFF);

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return successColor;
      case 'REJECTED':
        return errorColor;
      case 'PENDING':
      default:
        return warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);
    final isPending = request.status.toUpperCase() == 'PENDING';
    final isAccepted = request.status.toUpperCase() == 'ACCEPTED';
    final isRejected = request.status.toUpperCase() == 'REJECTED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
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
          // Header: Sender Profile & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sender',
                        style: TextStyle(
                          fontSize: 11,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Parcel Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.parcelDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.scale_rounded,
                          color: subtitleColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.parcelWeight} kg',
                          style: const TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${request.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Route: Source -> Destination
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                request.source,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: subtitleColor, size: 14),
              ),
              const Icon(Icons.place_rounded, color: secondaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                request.destination,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: const BorderSide(color: errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isAccepted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: successColor, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Request Accepted',
                        style: TextStyle(
                          color: successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: onActiveDeliveryTap,
                      icon: const Icon(Icons.navigation_rounded, size: 16),
                      label: const Text(
                        'View Active Delivery',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isRejected) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_rounded, color: errorColor, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Request Rejected',
                    style: TextStyle(
                      color: errorColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
