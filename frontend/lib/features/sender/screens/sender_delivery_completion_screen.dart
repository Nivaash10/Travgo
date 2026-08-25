import 'package:flutter/material.dart';
import '../data/sender_mock_delivery_completion_data.dart';
import '../models/sender_delivery_completion.dart';
import '../widgets/sender_proof_of_delivery_badge.dart';
import 'my_bookings_screen.dart';
import 'sender_delivery_feedback_screen.dart';
import 'sender_proof_viewer_screen.dart';

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
      _completion = SenderMockDeliveryCompletionData.getCompletionForBooking(
        id,
      );
    }
  }

  void _navigateToProofViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderProofViewerScreen(completion: _completion),
      ),
    );
  }

  void _navigateToMyBookings() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Completed')),
      body: SafeArea(child: _buildBody(context, theme)),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
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
              Icon(
                Icons.error_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load delivery completion details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Status')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Big Success Banner Card
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1FAE5), // emerald-100
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.task_alt,
                              size: 32,
                              color: Color(0xFF059669), // emerald-600
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Delivery Completed!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your parcel was successfully handed over to receiver ${_completion.receiverName ?? "Recipient"}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              'Booking ID: ${_completion.bookingId}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Verified Handover Stages Badges Card
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
                              'VERIFIED HANDOVER STAGES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Color(0xFF059669),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'PICKED UP',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          'OTP Verified',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Color(0xFF059669),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'IN TRANSIT',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          'Highway Route',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFA7F3D0),
                                      ),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 18,
                                          color: Color(0xFF059669),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'DELIVERED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF065F46),
                                          ),
                                        ),
                                        Text(
                                          'Handover Done',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF047857),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Shipment Summary Card
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
                              'SHIPMENT SUMMARY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            _RowLine(
                              label: 'Carrier Traveller',
                              value: _completion.travellerName,
                            ),
                            _RowLine(
                              label: 'Route',
                              value: 'Coimbatore â†’ ${_completion.destination}',
                            ),
                            _RowLine(
                              label: 'Delivered Item',
                              value:
                                  '${_completion.parcelDescription} (${_completion.parcelWeightKg} kg)',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Escrow Payout',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    'â‚¹220 Released',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Proof of Delivery Card
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
                                const Text(
                                  'PROOF OF DELIVERY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SenderProofOfDeliveryBadge(state: proofState),
                              ],
                            ),
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            _RowLine(
                              label: 'Status',
                              value: _completion.proofOfDeliveryAvailable
                                  ? 'Digital Proof Verified'
                                  : 'Proof Generation Pending',
                            ),
                            if (_completion.proofType != null)
                              _RowLine(
                                label: 'Proof Type',
                                value: _completion.proofType!,
                              ),
                            if (_completion.proofReference != null)
                              _RowLine(
                                label: 'Reference Code',
                                value: _completion.proofReference!,
                              ),
                            const SizedBox(height: 12),
                            if (_completion.proofOfDeliveryAvailable)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _navigateToProofViewer,
                                  icon: const Icon(Icons.receipt_long),
                                  label: const Text(
                                    'View Digital Proof',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _navigateToMyBookings,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        foregroundColor: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'All Bookings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SenderDeliveryFeedbackScreen(
                              bookingId: _completion.bookingId,
                              requestId: _completion.requestId,
                              travellerName: _completion.travellerName,
                              route: 'Coimbatore â†’ ${_completion.destination}',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text(
                        'Rate Traveller',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  final String label;
  final String value;

  const _RowLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
