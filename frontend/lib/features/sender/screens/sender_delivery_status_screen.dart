import 'package:flutter/material.dart';
import '../models/sender_delivery_status.dart';
import '../widgets/sender_delivery_status_badge.dart';
import '../widgets/sender_delivery_timeline.dart';
import 'sender_tracking_screen.dart';

/// Screen displaying the status and tracking timeline for a specific Sender delivery request.
class SenderDeliveryStatusScreen extends StatelessWidget {
  final SenderDeliveryStatusItem statusItem;

  const SenderDeliveryStatusScreen({
    super.key,
    required this.statusItem,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDefaultStatusMessage(SenderDeliveryStatus status) {
    switch (status) {
      case SenderDeliveryStatus.pending:
        return 'Waiting for traveller acceptance.';
      case SenderDeliveryStatus.accepted:
        return 'Traveller has accepted your delivery request.';
      case SenderDeliveryStatus.rejected:
        return 'Traveller declined this request.';
      case SenderDeliveryStatus.pickupPending:
        return 'Pickup pending. Prepare your parcel for collection.';
      case SenderDeliveryStatus.pickedUp:
        return 'Parcel has been picked up by the traveller.';
      case SenderDeliveryStatus.inTransit:
        return 'Your parcel is currently in transit.';
      case SenderDeliveryStatus.delivered:
        return 'Parcel has been delivered successfully.';
      case SenderDeliveryStatus.cancelled:
        return 'Delivery request was cancelled.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = statusItem.request;
    final traveller = request.traveller;

    final statusMessage = statusItem.statusMessage ??
        _getDefaultStatusMessage(statusItem.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Status'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Traveller & Status Header Card
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
                          Expanded(
                            child: Text(
                              traveller.travellerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (traveller.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[600]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      size: 14, color: Colors.green[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        traveller.route,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Travel: ${traveller.travelDateTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SenderDeliveryStatusBadge(status: statusItem.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Message Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Timeline Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERY LIFECYCLE',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 20),
                      SenderDeliveryTimeline(statusItem: statusItem),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Parcel Details Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PARCEL DETAILS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                          label: 'Description', value: request.parcelDescription),
                      _DetailRow(
                          label: 'Category', value: request.parcelCategory),
                      _DetailRow(
                          label: 'Weight', value: '${request.parcelWeightKg} kg'),
                      if (request.specialInstructions != null &&
                          request.specialInstructions!.isNotEmpty)
                        _DetailRow(
                            label: 'Special Instructions',
                            value: request.specialInstructions!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Details Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERY SUMMARY',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Pickup Location',
                        value: statusItem.pickupLocation ?? request.searchQuery.source,
                      ),
                      _DetailRow(
                        label: 'Delivery Location',
                        value: statusItem.deliveryLocation ?? request.searchQuery.destination,
                      ),
                      _DetailRow(
                        label: 'Price',
                        value: '₹${traveller.priceRupees.toStringAsFixed(0)}',
                      ),
                      _DetailRow(
                        label: 'Created Date',
                        value: _formatDate(statusItem.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SenderTrackingScreen(
                          requestId: statusItem.requestId,
                          bookingId: statusItem.requestId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.navigation_outlined),
                  label: Text(
                    statusItem.status == SenderDeliveryStatus.delivered
                        ? 'View Tracking History'
                        : 'Track Parcel',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
