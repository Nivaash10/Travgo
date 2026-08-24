import 'package:flutter/material.dart';
import '../models/traveler_trip.dart';
import '../repository/parcel_request_repository.dart';
import 'incoming_requests_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final TravelerTrip trip;

  const TripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

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

  Future<void> _onViewRequestsPressed(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingRequestsScreen(tripId: widget.trip.id),
      ),
    );
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final statusColor = _getStatusColor(trip.status);
    final requestCount = ParcelRequestRepository().getRequestsForTrip(trip.id).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trip Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route & Status Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        '₹${trip.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Route Flow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.trip_origin_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                          Container(
                            width: 2,
                            height: 36,
                            color: borderColor,
                          ),
                          const Icon(
                            Icons.place_rounded,
                            color: secondaryColor,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ORIGIN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              trip.source,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'DESTINATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              trip.destination,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Trip Information Breakdown Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    iconColor: primaryColor,
                    label: 'Travel Date',
                    value: _formatDate(trip.travelDate),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),

                  _buildDetailRow(
                    icon: Icons.access_time_rounded,
                    iconColor: secondaryColor,
                    label: 'Travel Time',
                    value: trip.travelTime,
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),

                  _buildDetailRow(
                    icon: Icons.scale_rounded,
                    iconColor: primaryColor,
                    label: 'Available Capacity',
                    value: '${trip.availableWeight} kg',
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),

                  _buildDetailRow(
                    icon: Icons.currency_rupee_rounded,
                    iconColor: primaryColor,
                    label: 'Price',
                    value: '₹${trip.price.toStringAsFixed(0)}',
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),

                  _buildDetailRow(
                    icon: Icons.handshake_outlined,
                    iconColor: accentColor,
                    label: 'Price Negotiable',
                    value: trip.isNegotiable ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Incoming Requests Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inbox_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incoming Requests',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$requestCount parcel request${requestCount == 1 ? '' : 's'} received',
                          style: const TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // View Requests Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _onViewRequestsPressed(context),
                icon: const Icon(Icons.inbox_outlined, size: 20),
                label: const Text(
                  'View Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: subtitleColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
