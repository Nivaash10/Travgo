import 'package:flutter/material.dart';
import '../models/sender_delivery_status.dart';
import '../widgets/sender_delivery_status_badge.dart';
import '../widgets/sender_delivery_timeline.dart';
import 'sender_tracking_screen.dart';

/// Screen displaying the status and tracking timeline for a specific Sender delivery request.
class SenderDeliveryStatusScreen extends StatelessWidget {
  final SenderDeliveryStatusItem statusItem;

  const SenderDeliveryStatusScreen({super.key, required this.statusItem});

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
    final request = statusItem.request;
    final traveller = request.traveller;
    final statusMessage =
        statusItem.statusMessage ?? _getDefaultStatusMessage(statusItem.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Status')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Booking Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Tracking ID: ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                              children: [
                                TextSpan(
                                  text: statusItem.requestId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SenderDeliveryStatusBadge(status: statusItem.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            request.searchQuery.source,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            request.searchQuery.destination,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Traveller details row
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  child: Text(
                                    traveller.travellerName.isNotEmpty
                                        ? traveller.travellerName[0]
                                              .toUpperCase()
                                        : 'T',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      traveller.travellerName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'Verified Courier',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Calling ${traveller.travellerName}...',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.call,
                                      size: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Chat with ${traveller.travellerName} is open',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.chat,
                                      size: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Status Message / State Guidance Banner
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: statusItem.status == SenderDeliveryStatus.delivered
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusItem.status == SenderDeliveryStatus.delivered
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusItem.status == SenderDeliveryStatus.delivered
                          ? Icons.task_alt
                          : Icons.info_outline,
                      size: 20,
                      color: statusItem.status == SenderDeliveryStatus.delivered
                          ? const Color(0xFF059669)
                          : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              statusItem.status ==
                                  SenderDeliveryStatus.delivered
                              ? const Color(0xFF065F46)
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Delivery Lifecycle Timeline Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DELIVERY LIFECYCLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      SenderDeliveryTimeline(statusItem: statusItem),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Parcel Details Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PARCEL DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _DetailRow(
                        label: 'Description',
                        value: request.parcelDescription,
                      ),
                      _DetailRow(
                        label: 'Category',
                        value: request.parcelCategory,
                      ),
                      _DetailRow(
                        label: 'Weight',
                        value: '${request.parcelWeightKg} kg',
                      ),
                      if (request.specialInstructions != null &&
                          request.specialInstructions!.isNotEmpty)
                        _DetailRow(
                          label: 'Special Instructions',
                          value: request.specialInstructions!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Action Button
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
                  icon: Icon(
                    statusItem.status == SenderDeliveryStatus.delivered
                        ? Icons.receipt_long
                        : Icons.navigation_outlined,
                    size: 18,
                  ),
                  label: Text(
                    statusItem.status == SenderDeliveryStatus.delivered
                        ? 'View Delivery Confirmation'
                        : 'Open Live Map Tracking',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
