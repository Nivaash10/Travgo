import 'package:flutter/material.dart';
import '../data/sender_mock_booking_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_status.dart';
import '../widgets/sender_booking_card.dart';
import 'search_route_screen.dart';
import 'sender_booking_detail_screen.dart';

/// Available filter options for Sender bookings.
enum BookingFilterCategory { all, active, pending, completed, cancelled }

/// Screen displaying all Sender bookings / delivery requests with filtering and actions.
class MyBookingsScreen extends StatefulWidget {
  final List<SenderBooking>? initialBookings;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateRequest;

  const MyBookingsScreen({
    super.key,
    this.initialBookings,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onCreateRequest,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late List<SenderBooking> _bookings;
  BookingFilterCategory _selectedFilter = BookingFilterCategory.all;

  @override
  void initState() {
    super.initState();
    _bookings = List.from(
      widget.initialBookings ?? SenderMockBookingData.getMockBookings(),
    );
  }

  int get _totalCount => _bookings.length;

  int get _activeCount {
    return _bookings.where((b) {
      return b.status == SenderDeliveryStatus.accepted ||
          b.status == SenderDeliveryStatus.pickupPending ||
          b.status == SenderDeliveryStatus.pickedUp ||
          b.status == SenderDeliveryStatus.inTransit;
    }).length;
  }

  List<SenderBooking> get _filteredBookings {
    switch (_selectedFilter) {
      case BookingFilterCategory.all:
        return _bookings;
      case BookingFilterCategory.active:
        return _bookings.where((b) {
          return b.status == SenderDeliveryStatus.accepted ||
              b.status == SenderDeliveryStatus.pickupPending ||
              b.status == SenderDeliveryStatus.pickedUp ||
              b.status == SenderDeliveryStatus.inTransit;
        }).toList();
      case BookingFilterCategory.pending:
        return _bookings.where((b) {
          return b.status == SenderDeliveryStatus.pending;
        }).toList();
      case BookingFilterCategory.completed:
        return _bookings.where((b) {
          return b.status == SenderDeliveryStatus.delivered;
        }).toList();
      case BookingFilterCategory.cancelled:
        return _bookings.where((b) {
          return b.status == SenderDeliveryStatus.cancelled ||
              b.status == SenderDeliveryStatus.rejected;
        }).toList();
    }
  }

  void _showCancelConfirmation(SenderBooking booking) {
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
              _cancelBooking(booking);
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

  void _cancelBooking(SenderBooking booking) {
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      setState(() {
        _bookings[index] = _bookings[index].copyWith(
          status: SenderDeliveryStatus.cancelled,
          canCancel: false,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery request cancelled.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onBookingUpdated(SenderBooking updated) {
    final index = _bookings.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      setState(() {
        _bookings[index] = updated;
      });
    }
  }

  void _navigateToDetail(SenderBooking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderBookingDetailScreen(
          booking: booking,
          onBookingUpdated: _onBookingUpdated,
        ),
      ),
    );
  }

  void _navigateToCreateRequest() {
    if (widget.onCreateRequest != null) {
      widget.onCreateRequest!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SearchRouteScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Bar
            if (!widget.isLoading &&
                widget.errorMessage == null &&
                _bookings.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_totalCount total bookings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '$_activeCount active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

            // Filter Chips Bar
            if (!widget.isLoading &&
                widget.errorMessage == null &&
                _bookings.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', BookingFilterCategory.all),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', BookingFilterCategory.active),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', BookingFilterCategory.pending),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', BookingFilterCategory.completed),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled', BookingFilterCategory.cancelled),
                    ],
                  ),
                ),
              ),

            // Main Content Area
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, BookingFilterCategory category) {
    final isSelected = _selectedFilter == category;
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = category;
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
                'Unable to load bookings',
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

    // 3. Overall Empty State
    if (_bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No bookings yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your delivery requests and bookings will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToCreateRequest,
                icon: const Icon(Icons.add),
                label: const Text('Create Delivery Request'),
              ),
            ],
          ),
        ),
      );
    }

    final displayItems = _filteredBookings;

    // Filter Empty State
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
                'No ${_selectedFilter.name} bookings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = BookingFilterCategory.all;
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
        final booking = displayItems[index];
        return SenderBookingCard(
          booking: booking,
          onViewDetails: () => _navigateToDetail(booking),
          onCancel: booking.canCancel
              ? () => _showCancelConfirmation(booking)
              : null,
        );
      },
    );
  }
}
