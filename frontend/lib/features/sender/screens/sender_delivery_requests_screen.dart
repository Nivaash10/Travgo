import 'package:flutter/material.dart';
import '../models/sender_delivery_status.dart';
import '../widgets/sender_delivery_request_card.dart';
import 'sender_delivery_status_screen.dart';

/// Available filter categories for Sender delivery requests.
enum SenderBookingFilter { all, active, pending, completed }

/// Screen displaying a list of Sender delivery requests ("My Bookings") with status filtering.
class SenderDeliveryRequestsScreen extends StatefulWidget {
  final List<SenderDeliveryStatusItem> items;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onSearchTravellers;

  const SenderDeliveryRequestsScreen({
    super.key,
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onSearchTravellers,
  });

  @override
  State<SenderDeliveryRequestsScreen> createState() =>
      _SenderDeliveryRequestsScreenState();
}

class _SenderDeliveryRequestsScreenState
    extends State<SenderDeliveryRequestsScreen> {
  SenderBookingFilter _selectedFilter = SenderBookingFilter.all;

  List<SenderDeliveryStatusItem> get _filteredItems {
    switch (_selectedFilter) {
      case SenderBookingFilter.all:
        return widget.items;
      case SenderBookingFilter.active:
        return widget.items.where((item) {
          return item.status == SenderDeliveryStatus.accepted ||
              item.status == SenderDeliveryStatus.pickupPending ||
              item.status == SenderDeliveryStatus.pickedUp ||
              item.status == SenderDeliveryStatus.inTransit;
        }).toList();
      case SenderBookingFilter.pending:
        return widget.items.where((item) {
          return item.status == SenderDeliveryStatus.pending;
        }).toList();
      case SenderBookingFilter.completed:
        return widget.items.where((item) {
          return item.status == SenderDeliveryStatus.delivered ||
              item.status == SenderDeliveryStatus.rejected ||
              item.status == SenderDeliveryStatus.cancelled;
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Bar (only if not loading, no error, and items not empty)
            if (!widget.isLoading &&
                widget.errorMessage == null &&
                widget.items.isNotEmpty)
              _buildFilterBar(context),

            // Main Content Area
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', SenderBookingFilter.all),
            const SizedBox(width: 8),
            _buildFilterChip('Active', SenderBookingFilter.active),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', SenderBookingFilter.pending),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', SenderBookingFilter.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, SenderBookingFilter filter) {
    final isSelected = _selectedFilter == filter;
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Loading State
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Unable to load delivery requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
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

    // 3. Empty State (Overall empty or Filter empty)
    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No bookings yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your delivery requests will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onSearchTravellers ??
                    () => Navigator.of(context).pop(),
                icon: const Icon(Icons.search),
                label: const Text('Search Travellers'),
              ),
            ],
          ),
        ),
      );
    }

    final displayItems = _filteredItems;

    if (displayItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_alt_off_outlined,
                  size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No ${_selectedFilter.name} bookings found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = SenderBookingFilter.all;
                  });
                },
                child: const Text('Show All Bookings'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Populated List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return SenderDeliveryRequestCard(
          statusItem: item,
          onViewDetails: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SenderDeliveryStatusScreen(
                  statusItem: item,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
