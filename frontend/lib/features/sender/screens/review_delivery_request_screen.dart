import 'package:flutter/material.dart';
import '../models/sender_delivery_request.dart';
import '../../traveler/repository/traveler_trip_repository.dart';
import 'booking_confirmation_screen.dart';
import 'matching_travellers_screen.dart';

/// Step 4 of Sender Delivery Workflow: Review Delivery Request.
class ReviewDeliveryRequestScreen extends StatelessWidget {
  final SenderDeliveryRequest request;
  final ValueChanged<SenderDeliveryRequest>? onSubmitRequest;

  const ReviewDeliveryRequestScreen({
    super.key,
    required this.request,
    this.onSubmitRequest,
  });

  void _onFindMatchingTravellers(BuildContext context) {
    if (onSubmitRequest != null) {
      onSubmitRequest!(request);
      return;
    }

    final matches = TravelerTripRepository().findMatches(
      request.searchQuery.source,
      request.searchQuery.destination,
      weight: request.parcelWeightKg,
    );

    if (matches.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MatchingTravellersScreen(
            query: request.searchQuery,
            deliveryRequest: request,
            travellerMatches: matches,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            request: request,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final receiver = request.receiver;
    final traveller = request.traveller;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Step 4: Review Delivery Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Progress Indicator
              Row(
                children: [
                  _buildStepDot(number: '1', title: 'Route', isComplete: true),
                  _buildStepLine(isComplete: true),
                  _buildStepDot(number: '2', title: 'Receiver', isComplete: true),
                  _buildStepLine(isComplete: true),
                  _buildStepDot(number: '3', title: 'Parcel', isComplete: true),
                  _buildStepLine(isComplete: true),
                  _buildStepDot(number: '4', title: 'Review', isActive: true),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Review Delivery Request',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please verify all details before submitting.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Traveller Details Section
              _ReviewSectionCard(
                title: 'TRAVELLER DETAILS',
                icon: Icons.person_outline,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        traveller.travellerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (traveller.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Verified',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(label: 'Route', value: traveller.route),
                  _DetailRow(label: 'Travel Date/Time', value: traveller.travelDateTime),
                  if (traveller.rating != null)
                    _DetailRow(label: 'Rating', value: '★ ${traveller.rating!.toStringAsFixed(1)}'),
                ],
              ),
              const SizedBox(height: 16),

              // Route & Schedule Card
              _ReviewSectionCard(
                title: 'ROUTE & SCHEDULE',
                icon: Icons.alt_route,
                children: [
                  _DetailRow(label: 'Pickup Location', value: request.searchQuery.source),
                  _DetailRow(label: 'Destination', value: request.searchQuery.destination),
                  if (request.searchQuery.date != null)
                    _DetailRow(
                      label: 'Travel Date',
                      value: '${request.searchQuery.date!.day}/${request.searchQuery.date!.month}/${request.searchQuery.date!.year}',
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Receiver Details Card
              _ReviewSectionCard(
                title: 'RECEIVER DETAILS',
                icon: Icons.person_pin_circle_outlined,
                children: [
                  _DetailRow(label: 'Full Name', value: receiver?.fullName ?? 'Priya Sharma'),
                  _DetailRow(label: 'Phone Number', value: receiver?.phoneNumber ?? '+91 98765 01234'),
                  _DetailRow(label: 'Delivery Address', value: receiver?.deliveryAddress ?? request.searchQuery.destination),
                  if (receiver?.landmark != null && receiver!.landmark!.isNotEmpty)
                    _DetailRow(label: 'Landmark', value: receiver.landmark!),
                  if (receiver?.pincode != null && receiver!.pincode!.isNotEmpty)
                    _DetailRow(label: 'PIN Code', value: receiver.pincode!),
                ],
              ),
              const SizedBox(height: 16),

              // Parcel Details Card
              _ReviewSectionCard(
                title: 'PARCEL DETAILS',
                icon: Icons.inventory_2_outlined,
                children: [
                  _DetailRow(label: 'Category', value: request.parcelCategory),
                  _DetailRow(label: 'Description', value: request.parcelDescription),
                  _DetailRow(label: 'Weight', value: '${request.parcelWeightKg} kg'),
                  _DetailRow(label: 'Quantity', value: '${request.parcelQuantity} pcs'),
                  if (request.specialInstructions != null && request.specialInstructions!.isNotEmpty)
                    _DetailRow(label: 'Special Instructions', value: request.specialInstructions!),
                ],
              ),
              const SizedBox(height: 16),

              // Delivery & Price Summary Card
              _ReviewSectionCard(
                title: 'DELIVERY & PRICE SUMMARY',
                icon: Icons.payments_outlined,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Price',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${traveller.priceRupees.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Back & Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _onFindMatchingTravellers(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit Delivery Request',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot({required String number, required String title, bool isActive = false, bool isComplete = false}) {
    final color = isComplete || isActive ? const Color(0xFF2563EB) : Colors.grey[400]!;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isComplete ? const Color(0xFF10B981) : (isActive ? const Color(0xFF2563EB) : Colors.grey[200]),
          child: isComplete
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: color),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isComplete}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        color: isComplete ? const Color(0xFF10B981) : Colors.grey[300],
      ),
    );
  }
}

class _ReviewSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ReviewSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
