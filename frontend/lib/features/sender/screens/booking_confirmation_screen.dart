import 'package:flutter/material.dart';
import '../../otp/services/otp_service.dart';
import '../../traveler/models/parcel_request.dart';
import '../../traveler/repository/parcel_request_repository.dart';
import '../data/sender_mock_booking_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_delivery_status.dart';
import 'sender_delivery_status_screen.dart';
import 'sender_payment_screen.dart';

/// Screen displaying confirmation for a prepared Sender delivery request.
class BookingConfirmationScreen extends StatelessWidget {
  final SenderDeliveryRequest request;

  BookingConfirmationScreen({
    super.key,
    required this.request,
  }) {
    _syncRequest();
  }

  void _syncRequest() {
    final reqId = 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final bkgId = 'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    ParcelRequestRepository().addRequest(
      ParcelRequest(
        id: reqId,
        tripId: 'trip_1',
        senderName: 'Ramesh Kumar',
        parcelDescription: request.parcelDescription,
        parcelWeight: request.parcelWeightKg,
        source: request.searchQuery.source,
        destination: request.searchQuery.destination,
        price: request.traveller.priceRupees,
        status: 'PENDING',
      ),
    );

    SenderMockBookingData.addBooking(
      SenderBooking(
        id: bkgId,
        request: request,
        status: SenderDeliveryStatus.pending,
        createdAt: DateTime.now(),
        deliveryPrice: request.traveller.priceRupees,
        pickupLocation: '${request.searchQuery.source} Central',
        deliveryLocation: '${request.searchQuery.destination} Station',
        travellerName: request.traveller.travellerName,
      ),
    );

    OtpService.instance.generatePickupOtp();
  }

  void _onViewStatusPressed(BuildContext context) {
    final statusItem = SenderDeliveryStatusItem(
      requestId: 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      request: request,
      status: SenderDeliveryStatus.pending,
      createdAt: DateTime.now(),
      statusMessage: 'Waiting for traveller acceptance.',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderDeliveryStatusScreen(
          statusItem: statusItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final traveller = request.traveller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Submitted'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green[600],
              ),
              const SizedBox(height: 20),
              Text(
                'Delivery Request Submitted',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your delivery request has been prepared successfully.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Official backend confirmation and traveller notification will be connected in an upcoming phase.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Request Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Traveller:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            traveller.travellerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Receiver:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            request.receiver?.fullName ?? 'Priya Sharma',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Route:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            traveller.route,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Parcel Category:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            request.parcelCategory,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Parcel Weight:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            '${request.parcelWeightKg} kg',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Price:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            '₹${traveller.priceRupees.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
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
                              OtpService.instance.generatePickupOtp().otp,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Share this 4-digit code with ${traveller.travellerName} upon parcel pickup',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm & Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SenderPaymentScreen(
                          request: request,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    'Confirm & Pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // View Status Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _onViewStatusPressed(context),
                  icon: const Icon(Icons.alt_route),
                  label: const Text(
                    'View Delivery Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Dashboard Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Sender Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
