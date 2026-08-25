import 'package:flutter/material.dart';
import '../models/sender_search_query.dart';
import '../models/sender_traveller_match.dart';
import '../widgets/sender_traveller_card.dart';
import 'parcel_details_screen.dart';

/// Screen displaying matching travellers for a given [SenderSearchQuery].
class MatchingTravellersScreen extends StatelessWidget {
  final SenderSearchQuery query;
  final List<SenderTravellerMatch> travellerMatches;
  final ValueChanged<SenderTravellerMatch>? onRequestDelivery;
  final VoidCallback? onModifySearch;
  final VoidCallback? onRetry;
  final bool isLoading;
  final String? errorMessage;

  const MatchingTravellersScreen({
    super.key,
    required this.query,
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Available Travellers'),
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
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _SummaryChip(
                        icon: Icons.trip_origin,
                        label:
                            'From: ${query.source.isNotEmpty ? query.source : "Any"}',
                      ),
                      _SummaryChip(
                        icon: Icons.location_on,
                        label:
                            'To: ${query.destination.isNotEmpty ? query.destination : "Any"}',
                      ),
                      _SummaryChip(
                        icon: Icons.calendar_today,
                        label: 'Date: ${_formatDate(query.date)}',
                      ),
                      if (query.parcelWeightKg != null)
                        _SummaryChip(
                          icon: Icons.scale,
                          label: 'Weight: ${query.parcelWeightKg} kg',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Filter Chips Row (matching Stitch UI)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Wrap(
                spacing: 8.0,
                children: const [
                  Chip(label: Text('All Trips')),
                  Chip(label: Text('Car')),
                  Chip(label: Text('Train')),
                  Chip(label: Text('EV Car')),
                ],
              ),
            ),

            // Content Area (Loading / Error / Empty / Populated List)
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Loading State
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State
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
              const SizedBox(height: 6),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
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

    // 3. Empty State
    if (travellerMatches.isEmpty) {
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
                'No travellers found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Travellers matching your route will appear here.',
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

    // 4. Populated Matches List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: travellerMatches.length,
      itemBuilder: (context, index) {
        final match = travellerMatches[index];
        return SenderTravellerCard(
          match: match,
          onRequestDelivery: (selected) {
            if (onRequestDelivery != null) {
              onRequestDelivery!(selected);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ParcelDetailsScreen(
                    searchQuery: query,
                    traveller: selected,
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
