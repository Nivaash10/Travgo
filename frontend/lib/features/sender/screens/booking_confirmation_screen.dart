import 'package:flutter/material.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_delivery_status.dart';
import 'sender_delivery_status_screen.dart';
import 'sender_payment_screen.dart';

/// Screen displaying confirmation for a prepared Sender delivery request.
class BookingConfirmationScreen extends StatelessWidget {
  final SenderDeliveryRequest request;

  const BookingConfirmationScreen({
    super.key,
    required this.request,
  });

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
                            'â‚¹${traveller.priceRupees.toStringAsFixed(0)}',
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
              const SizedBox(height: 32),

              // Proceed to Payment Button
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
                    'Proceed to Payment',
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
