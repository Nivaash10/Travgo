import 'package:flutter/material.dart';
import '../../../models/receiver_model.dart';
import '../data/sender_mock_booking_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_delivery_status.dart';
import '../models/sender_search_query.dart';
import '../models/sender_traveller_match.dart';
import '../widgets/sender_traveller_card.dart';
import '../../traveler/repository/traveler_trip_repository.dart';
import 'sender_booking_detail_screen.dart';

/// Screen displaying Step 4: Available Travellers for a given [SenderSearchQuery].
class MatchingTravellersScreen extends StatelessWidget {
  final SenderSearchQuery query;
  final ReceiverModel? receiver;
  final String? parcelDescription;
  final String? parcelCategory;
  final int? parcelQuantity;
  final String? specialInstructions;

  final SenderDeliveryRequest? deliveryRequest;
  final List<SenderTravellerMatch> travellerMatches;
  final ValueChanged<SenderTravellerMatch>? onRequestDelivery;
  final VoidCallback? onModifySearch;
  final VoidCallback? onRetry;
  final bool isLoading;
  final String? errorMessage;

  const MatchingTravellersScreen({
    super.key,
    required this.query,
    this.receiver,
    this.parcelDescription,
    this.parcelCategory,
    this.parcelQuantity,
    this.specialInstructions,
    this.deliveryRequest,
    this.travellerMatches = const [],
    this.onRequestDelivery,
    this.onModifySearch,
    this.onRetry,
    this.isLoading = false,
    this.errorMessage,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Any date';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Resolve matching travellers from repository if custom matches not passed
    final resolvedMatches = travellerMatches.isNotEmpty
        ? travellerMatches
        : TravelerTripRepository().findMatches(
            query.source,
            query.destination,
            weight: query.parcelWeightKg,
            date: query.date,
          );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Step 4: Available Travellers'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: onModifySearch),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Summary Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Summary',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton.icon(
                        onPressed:
                            onModifySearch ?? () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text(
                          'Modify Search',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SummaryChip(
                        icon: Icons.flight_takeoff,
                        label: 'From: ${query.source}',
                      ),
                      const SizedBox(width: 12),
                      _SummaryChip(
                        icon: Icons.flight_land,
                        label: 'To: ${query.destination}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _SummaryChip(
                        icon: Icons.calendar_today,
                        label: 'Date: ${_formatDate(query.date)}',
                      ),
                      if (query.parcelWeightKg != null) ...[
                        const SizedBox(width: 12),
                        _SummaryChip(
                          icon: Icons.scale,
                          label: 'Weight: ${query.parcelWeightKg} kg',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Content Area (Loading / Error / Empty / Populated List)
            Expanded(child: _buildContent(context, resolvedMatches)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SenderTravellerMatch> matches) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load travellers',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 56,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No matching travellers found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We couldn't find an active traveller for this route and date.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onModifySearch ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('Modify Search'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return SenderTravellerCard(
          match: match,
          onRequestDelivery: (selected) {
            if (onRequestDelivery != null) {
              onRequestDelivery!(selected);
            } else {
              final newBooking = SenderBooking(
                id: 'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                status: SenderDeliveryStatus.pending,
                createdAt: DateTime.now(),
                deliveryPrice: selected.priceRupees,
                canCancel: true,
                canViewStatus: true,
                pickupLocation: query.source,
                deliveryLocation: query.destination,
                travellerName: selected.travellerName,
                request: SenderDeliveryRequest(
                  searchQuery: query,
                  traveller: selected,
                  receiver: receiver ??
                      ReceiverModel(
                        id: 'REC-101',
                        fullName: 'Priya Sharma',
                        phoneNumber: '+91 98765 01234',
                        deliveryAddress: 'Flat 402, Sunshine Apartments, Anna Nagar, ${query.destination}',
                      ),
                  parcelDescription: parcelDescription ?? 'Books and documents',
                  parcelWeightKg: query.parcelWeightKg ?? 2.5,
                  parcelCategory: parcelCategory ?? 'Documents',
                  parcelQuantity: parcelQuantity ?? 1,
                  specialInstructions: specialInstructions,
                ),
              );

              SenderMockBookingData.addBooking(newBooking);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delivery request sent to ${selected.travellerName}!'),
                  backgroundColor: const Color(0xFF2563EB),
                ),
              );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SenderBookingDetailScreen(
                    booking: newBooking,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
