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
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);

  Future<void> _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _navigateToTripDetails(TravelerTrip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trips = TravelerTripRepository().trips;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Trips (${trips.length})',
          style: const TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: primaryColor, size: 28),
            onPressed: _navigateToCreateTrip,
            tooltip: 'Create Trip',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: trips.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: trips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  trip: trip,
                  onTap: () => _navigateToTripDetails(trip),
                );
              },
            ),
      floatingActionButton: trips.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateTrip,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.luggage_outlined,
                size: 54,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No trips yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first trip to start accepting parcel requests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _navigateToCreateTrip,
              icon: const Icon(Icons.add_road_rounded),
              label: const Text(
                'Create a Trip',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
