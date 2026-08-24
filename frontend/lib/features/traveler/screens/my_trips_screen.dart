import 'package:flutter/material.dart';
import '../models/traveler_trip.dart';
import '../repository/traveler_trip_repository.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'trip_details_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  String _selectedStatusFilter = 'ALL';

  Future<void> _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );

    if (result == true) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _navigateToTripDetails(TravelerTrip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(trip: trip),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<TravelerTrip> _getFilteredTrips(List<TravelerTrip> allTrips) {
    if (_selectedStatusFilter == 'ALL') {
      return allTrips;
    }
    return allTrips
        .where((t) => t.status.toUpperCase() == _selectedStatusFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTrips = TravelerTripRepository().trips;
    final filteredTrips = _getFilteredTrips(allTrips);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1. Clean Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'My Trips',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${allTrips.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Your journeys and parcel-carrying opportunities',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _navigateToCreateTrip,
                    icon: const Icon(Icons.add_circle_rounded, color: primaryColor, size: 28),
                    tooltip: 'Create New Trip',
                  ),
                ],
              ),
            ),
          ),

          // 2. Status Filter Bar (if trips exist)
          if (allTrips.isNotEmpty)
            Container(
              height: 48,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildFilterChip('ALL', 'All (${allTrips.length})'),
                  _buildFilterChip(
                    'ACTIVE',
                    'Active (${allTrips.where((t) => t.status == 'ACTIVE').length})',
                  ),
                  _buildFilterChip(
                    'UPCOMING',
                    'Upcoming (${allTrips.where((t) => t.status == 'UPCOMING').length})',
                  ),
                  _buildFilterChip(
                    'COMPLETED',
                    'Completed (${allTrips.where((t) => t.status == 'COMPLETED').length})',
                  ),
                  _buildFilterChip(
                    'CANCELLED',
                    'Cancelled (${allTrips.where((t) => t.status == 'CANCELLED').length})',
                  ),
                ],
              ),
            ),

          // Main Content List or Empty State
          Expanded(
            child: filteredTrips.isEmpty
                ? _buildEmptyState(context, isFiltered: allTrips.isNotEmpty)
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: filteredTrips.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return TripCard(
                        trip: trip,
                        onTap: () => _navigateToTripDetails(trip),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: allTrips.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateTrip,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedStatusFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
        selected: isSelected,
        selectedColor: primaryColor,
        backgroundColor: const Color(0xFFF1F5F9),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.transparent,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedStatusFilter = filterKey;
            });
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isFiltered}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.alt_route_rounded,
                size: 50,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isFiltered ? 'No trips match this filter' : 'No journeys yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try selecting a different status filter above.'
                  : 'Your travel route can become someone\'s delivery route. Publish a trip to start carrying parcels.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (!isFiltered)
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _navigateToCreateTrip,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'Create Trip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
