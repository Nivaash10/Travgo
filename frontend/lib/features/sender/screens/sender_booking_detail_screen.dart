import 'package:flutter/material.dart';
import '../data/sender_mock_payment_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_status.dart';
import '../models/sender_payment.dart';
import '../widgets/sender_delivery_status_badge.dart';
import '../widgets/sender_delivery_timeline.dart';
import '../widgets/sender_payment_status_badge.dart';
import 'sender_delivery_completion_screen.dart';
import 'sender_delivery_feedback_screen.dart';
import 'sender_payment_screen.dart';
import 'sender_tracking_screen.dart';

/// Screen displaying detailed information for a specific Sender booking.
class SenderBookingDetailScreen extends StatefulWidget {
  final SenderBooking booking;
  final SenderPayment? initialPayment;
  final Function(SenderBooking)? onBookingUpdated;

  const SenderBookingDetailScreen({
    super.key,
    required this.booking,
    this.initialPayment,
    this.onBookingUpdated,
  });

  @override
  State<SenderBookingDetailScreen> createState() =>
      _SenderBookingDetailScreenState();
}

class _SenderBookingDetailScreenState extends State<SenderBookingDetailScreen> {
  late SenderBooking _booking;
  late SenderPayment _payment;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;

    if (widget.initialPayment != null) {
      _payment = widget.initialPayment!;
    } else {
      // Find matching mock payment or create default based on booking status
      final mockPayments = SenderMockPaymentData.getMockPayments();
      final match = mockPayments
          .where((p) => p.bookingId == _booking.id)
          .firstOrNull;

      if (match != null) {
        _payment = match;
      } else {
        final isPaid =
            _booking.status == SenderDeliveryStatus.delivered ||
            _booking.status == SenderDeliveryStatus.inTransit ||
            _booking.status == SenderDeliveryStatus.pickedUp;

        _payment = SenderPayment(
          paymentId: 'PAY-${_booking.id}',
          bookingId: _booking.id,
          requestId: 'REQ-${_booking.id}',
          amountRupees: _booking.deliveryPrice + 15.0,
          paymentMethod: 'UPI',
          status: isPaid
              ? SenderPaymentStatus.paid
              : SenderPaymentStatus.pending,
          createdAt: _booking.createdAt,
          paidAt: isPaid ? _booking.createdAt : null,
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  SenderDeliveryStatusItem _getDeliveryStatusItem() {
    return SenderDeliveryStatusItem(
      requestId: _booking.id,
      request: _booking.request,
      status: _booking.status,
      createdAt: _booking.createdAt,
      statusMessage: _getDefaultStatusMessage(_booking.status),
      pickupLocation: _booking.pickupLocation,
      deliveryLocation: _booking.deliveryLocation,
    );
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Delivery Request?'),
        content: const Text(
          'Are you sure you want to cancel this delivery request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _cancelBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking() {
    setState(() {
      _booking = _booking.copyWith(
        status: SenderDeliveryStatus.cancelled,
        canCancel: false,
      );
    });

    widget.onBookingUpdated?.call(_booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery request cancelled.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToTrackDelivery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderTrackingScreen(bookingId: _booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = _booking.request;
    final traveller = request.traveller;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
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
                          Text(
                            _booking.id,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SenderDeliveryStatusBadge(status: _booking.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        traveller.route,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${_formatDate(_booking.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TRAVGO Traveller Details Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRAVELLER DETAILS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 12),
                      _DetailRow(
                        label: 'Name',
                        value:
                            _booking.travellerName ?? traveller.travellerName,
                      ),
                      _DetailRow(
                        label: 'Status',
                        value: traveller.isVerified
                            ? 'Verified Traveller'
                            : 'Standard',
                      ),
                      if (traveller.rating != null)
                        _DetailRow(
                          label: 'Rating',
                          value: '★ ${traveller.rating!.toStringAsFixed(1)}',
                        ),
                      _DetailRow(label: 'Route', value: traveller.route),
                      _DetailRow(
                        label: 'Travel Date',
                        value: traveller.travelDateTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // RECEIVER DETAILS Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECEIVER DETAILS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Divider(height: 14),
                      _DetailRow(
                        label: 'Full Name',
                        value: request.receiver?.fullName ?? 'Priya Sharma',
                      ),
                      _DetailRow(
                        label: 'Phone Number',
                        value: request.receiver?.phoneNumber ?? '+91 98765 01234',
                      ),
                      _DetailRow(
                        label: 'Delivery Address',
                        value: request.receiver?.deliveryAddress ?? _booking.deliveryLocation ?? request.searchQuery.destination,
                      ),
                      if (request.receiver?.landmark != null && request.receiver!.landmark!.isNotEmpty)
                        _DetailRow(
                          label: 'Landmark',
                          value: request.receiver!.landmark!,
                        ),
                      if (request.receiver?.pincode != null && request.receiver!.pincode!.isNotEmpty)
                        _DetailRow(
                          label: 'PIN Code',
                          value: request.receiver!.pincode!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PARCEL DETAILS Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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
                      const Divider(height: 12),
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

              // DELIVERY SUMMARY Card
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
                        value:
                            _booking.pickupLocation ??
                            request.searchQuery.source,
                      ),
                      _DetailRow(
                        label: 'Delivery Location',
                        value:
                            _booking.deliveryLocation ??
                            request.searchQuery.destination,
                      ),
                      _DetailRow(
                        label: 'Delivery Price',
                        value: '₹${_booking.deliveryPrice.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PAYMENT INFORMATION Card
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
                            'PAYMENT INFORMATION',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SenderPaymentStatusBadge(status: _payment.status),
                        ],
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Amount',
                        value: '₹${_payment.amountRupees.toStringAsFixed(0)}',
                      ),
                      _DetailRow(
                        label: 'Payment Method',
                        value: _payment.paymentMethod,
                      ),
                      _DetailRow(
                        label: 'Payment ID',
                        value: _payment.paymentId,
                      ),
                    ],
                  ),
                ),
              ),
               const SizedBox(height: 16),

              // Pickup Verification OTP Card
              Card(
                color: const Color(0xFFEEF2FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.key, color: Color(0xFF4F46E5), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pickup Verification OTP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _booking.status == SenderDeliveryStatus.delivered || _booking.status == SenderDeliveryStatus.inTransit
                                  ? 'VERIFIED'
                                  : '4827',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Share this code with ${_booking.travellerName ?? "traveller"} upon parcel pickup.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      SenderDeliveryTimeline(
                        statusItem: _getDeliveryStatusItem(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status Banners & Actions
              // Status Banners & Actions
              if (_booking.status == SenderDeliveryStatus.pending) ...[
                Card(
                  color: const Color(0xFFEFF6FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_top_rounded, color: Color(0xFF2563EB), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Waiting for traveller to accept your request. Payment and tracking will become available after acceptance.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_booking.status == SenderDeliveryStatus.rejected) ...[
                Card(
                  color: const Color(0xFFFEF2F2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This traveller has declined your delivery request. Please select another traveller.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                          ),
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
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: const Text(
                      'Choose Another Traveller',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_booking.status == SenderDeliveryStatus.accepted && _payment.status != SenderPaymentStatus.paid) ...[
                Card(
                  color: const Color(0xFFECFDF5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFA7F3D0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Traveller accepted your delivery request. Complete payment to secure the delivery.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF065F46), fontWeight: FontWeight.bold),
                          ),
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
                          builder: (context) => SenderPaymentScreen(
                            booking: _booking,
                            onPaymentCompleted: (updatedPayment) {
                              setState(() {
                                _payment = updatedPayment;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: Text(
                      'Pay / Continue to Payment (₹${_booking.deliveryPrice.toInt()})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_booking.canViewStatus && _booking.status != SenderDeliveryStatus.pending && _booking.status != SenderDeliveryStatus.rejected)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToTrackDelivery,
                    icon: const Icon(Icons.alt_route),
                    label: const Text(
                      'Track Delivery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (_booking.status == SenderDeliveryStatus.delivered) ...[
                const SizedBox(height: 10),
                Card(
                  color: const Color(0xFFECFDF5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFA7F3D0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'DELIVERY COMPLETED ✓',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '✓ Pickup Verified  •  ✓ Traveller Tracked\n✓ Delivery OTP Verified  •  ✓ Parcel Delivered\nPayment: Escrow Released',
                          style: TextStyle(fontSize: 12, color: Color(0xFF047857), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SenderDeliveryCompletionScreen(
                                bookingId: _booking.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified_outlined, size: 16),
                        label: const Text(
                          'View Delivery Proof',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SenderDeliveryFeedbackScreen(
                                bookingId: _booking.id,
                                travellerName: _booking.travellerName,
                                route:
                                    '${_booking.request.searchQuery.source} → ${_booking.request.searchQuery.destination}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text(
                          'Rate Traveller',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_booking.canCancel) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _showCancelDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
