import 'package:flutter/material.dart';
import '../data/sender_mock_delivery_completion_data.dart';
import '../models/sender_delivery_completion.dart';
import '../widgets/sender_proof_of_delivery_badge.dart';
import 'my_bookings_screen.dart';
import 'sender_delivery_feedback_screen.dart';
import 'sender_proof_viewer_screen.dart';
import 'sender_tracking_screen.dart';

/// Screen displaying complete details for a delivered Sender parcel, including Proof of Delivery.
class SenderDeliveryCompletionScreen extends StatefulWidget {
  final SenderDeliveryCompletion? completion;
  final String? bookingId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SenderDeliveryCompletionScreen({
    super.key,
    this.completion,
    this.bookingId,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<SenderDeliveryCompletionScreen> createState() =>
      _SenderDeliveryCompletionScreenState();
}

class _SenderDeliveryCompletionScreenState
    extends State<SenderDeliveryCompletionScreen> {
  late SenderDeliveryCompletion _completion;

  @override
  void initState() {
    super.initState();
    if (widget.completion != null) {
      _completion = widget.completion!;
    } else {
      final id = widget.bookingId ?? 'BKG-105';
      _completion = SenderMockDeliveryCompletionData.getCompletionForBooking(id);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final minuteStr = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour}:$minuteStr';
  }

  void _navigateToProofViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderProofViewerScreen(
          completion: _completion,
        ),
      ),
    );
  }

  void _navigateToMyBookings() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MyBookingsScreen(),
      ),
      (route) => route.isFirst,
    );
  }

  void _navigateToTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderTrackingScreen(
          bookingId: _completion.bookingId,
          requestId: _completion.requestId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Completed'),
      ),
      body: SafeArea(
        child: _buildBody(context, theme),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    // 1. Loading State
    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading completion details...',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Unable to load delivery completion details',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Main Populated Content
    final proofState = _completion.proofOfDeliveryAvailable
        ? ProofOfDeliveryState.available
        : ProofOfDeliveryState.pending;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // Success Header
          Icon(
            Icons.check_circle,
            size: 72,
            color: Colors.green[600],
          ),
          const SizedBox(height: 12),
          Text(
            'Parcel Delivered Successfully',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _completion.deliveryMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),

          // Delivery Summary Card
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
                  Text(
                    'DELIVERY SUMMARY',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Divider(height: 20),
                  _RowLine(label: 'Booking ID', value: _completion.bookingId),
                  _RowLine(label: 'Destination', value: _completion.destination),
                  _RowLine(label: 'Traveller', value: _completion.travellerName),
                  _RowLine(
                    label: 'Delivered Date',
                    value: _formatDate(_completion.deliveredAt),
                  ),
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
                  _RowLine(label: 'Description', value: _completion.parcelDescription),
                  _RowLine(label: 'Category', value: _completion.parcelCategory),
                  _RowLine(label: 'Weight', value: '${_completion.parcelWeightKg} kg'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Receiver Confirmation Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECEIVER CONFIRMATION',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SenderProofOfDeliveryBadge(
                        state: ProofOfDeliveryState.confirmed,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _RowLine(
                    label: 'Recipient',
                    value: _completion.receiverName ?? 'Recipient Handover',
                  ),
                  const _RowLine(label: 'Confirmation Status', value: 'Confirmed via OTP'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Proof of Delivery Card
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
                      SenderProofOfDeliveryBadge(state: proofState),
                    ],
                  ),
                  const Divider(height: 20),
                  _RowLine(
                    label: 'Status',
                    value: _completion.proofOfDeliveryAvailable
                        ? 'Digital Proof Verified'
                        : 'Proof Generation Pending',
                  ),
                  if (_completion.proofType != null)
                    _RowLine(label: 'Proof Type', value: _completion.proofType!),
                  if (_completion.proofReference != null)
                    _RowLine(label: 'Reference Code', value: _completion.proofReference!),
                  const SizedBox(height: 12),
                  if (_completion.proofOfDeliveryAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _navigateToProofViewer,
                        icon: const Icon(Icons.receipt_long),
                        label: const Text(
                          'View Proof',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Proof of delivery document is currently being generated by traveller.',
                        style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SenderDeliveryFeedbackScreen(
                    bookingId: _completion.bookingId,
                    requestId: _completion.requestId,
                    travellerName: _completion.travellerName,
                    route: 'Coimbatore → ${_completion.destination}',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.star),
            label: const Text(
              'Rate Traveller',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _navigateToMyBookings,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Back to My Bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: _navigateToTracking,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Tracking History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  final String label;
  final String value;

  const _RowLine({
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
