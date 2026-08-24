import 'package:flutter/material.dart';
import '../models/traveler_trip.dart';
import '../repository/parcel_request_repository.dart';
import '../repository/traveler_trip_repository.dart';
import 'aadhaar_verification_screen.dart';
import 'create_trip_screen.dart';
import 'incoming_requests_screen.dart';
import 'my_trips_screen.dart';
import 'traveler_profile_screen.dart';
import 'trip_details_screen.dart';

class TravelerDashboardScreen extends StatefulWidget {
  const TravelerDashboardScreen({super.key});

  @override
  State<TravelerDashboardScreen> createState() => _TravelerDashboardScreenState();
}

class _TravelerDashboardScreenState extends State<TravelerDashboardScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);

  void _showPlaceholderSnackBar(BuildContext context, String featureTitle) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureTitle - Coming in future release'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showVerificationRequiredDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: cardColor,
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: subtitleColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AadhaarVerificationScreen(),
                  ),
                );
                if (mounted) {
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Verify Aadhaar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToCreateTrip() async {
    if (!TravelerTripRepository().isVerified) {
      _showVerificationRequiredDialog(
        title: 'Aadhaar Verification Required',
        message: 'You must verify your Aadhaar before creating a trip.',
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );
    if (result == true) {
      if (mounted) {
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyTripsScreen()),
        );
      }
    }
  }

  Future<void> _navigateToMyTrips() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyTripsScreen()),
    );
    setState(() {});
  }

  Future<void> _navigateToTripDetails(TravelerTrip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip)),
    );
    setState(() {});
  }

  Future<void> _navigateToIncomingRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncomingRequestsScreen()),
    );
    setState(() {});
  }

  Future<void> _navigateToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelerProfileScreen()),
    );
    setState(() {});
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final repository = TravelerTripRepository();
    final activeTrip = repository.activeTrip;
    final tripCount = repository.tripCount.toString();
    final requestCount = ParcelRequestRepository().getTotalRequestCount().toString();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TRAVGO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Traveler',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showPlaceholderSnackBar(context, 'Notifications'),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: textColor,
            ),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Welcome Message
            const Text(
              'Welcome back, Traveler!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your journeys and parcel requests.',
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
              ),
            ),

            const SizedBox(height: 16),

            // Verification Banner Card
            _buildVerificationBannerCard(),

            const SizedBox(height: 16),

            // Profile Summary Card
            _buildProfileSummaryCard(),

            const SizedBox(height: 24),

            // 2. Summary Cards
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context: context,
                    icon: Icons.directions_bus_rounded,
                    value: tripCount,
                    label: 'My Trips',
                    iconColor: primaryColor,
                    onTap: _navigateToMyTrips,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    context: context,
                    icon: Icons.markunread_mailbox_outlined,
                    value: requestCount,
                    label: 'Incoming Requests',
                    iconColor: secondaryColor,
                    onTap: _navigateToIncomingRequests,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.add_road_rounded,
              title: 'Create Trip',
              subtitle: 'Publish your upcoming journey',
              badgeColor: primaryColor,
              onTap: _navigateToCreateTrip,
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              context,
              icon: Icons.luggage_outlined,
              title: 'My Trips',
              subtitle: 'View and manage your active & past trips',
              badgeColor: secondaryColor,
              onTap: _navigateToMyTrips,
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              context,
              icon: Icons.inbox_outlined,
              title: 'Incoming Requests',
              subtitle: 'Review parcel delivery requests from senders',
              badgeColor: accentColor,
              onTap: _navigateToIncomingRequests,
            ),

            const SizedBox(height: 24),

            // 4. Active Trip Section
            const Text(
              'Active Trip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            if (activeTrip != null)
              _buildActiveTripCard(context, activeTrip)
            else
              _buildActiveTripEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBannerCard() {
    final isVerified = TravelerTripRepository().isVerified;

    if (!isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCD34D)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  '⚠ Identity Verification Required',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Verify your Aadhaar to become a Verified TRAVGO Traveler. Verified travelers can create trips and accept parcel requests.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF78350F),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AadhaarVerificationScreen(),
                    ),
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Verify Aadhaar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(
              Icons.verified_rounded,
              color: Color(0xFF10B981),
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✓ Verified Traveler',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your Aadhaar identity has been verified. Status: VERIFIED',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProfileSummaryCard() {
    final isVerified = TravelerTripRepository().isVerified;

    return InkWell(
      onTap: _navigateToProfile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person_rounded,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Traveler Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isVerified
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        color: isVerified ? successColor : const Color(0xFFD97706),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVerified ? 'Verified Traveler' : 'Not Verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isVerified ? successColor : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: badgeColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripCard(BuildContext context, TravelerTrip trip) {
    return InkWell(
      onTap: () => _navigateToTripDetails(trip),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE TRIP',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '₹${trip.price.toInt()}',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(fontSize: 11, color: subtitleColor),
                      ),
                      Text(
                        trip.source,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'To',
                        style: TextStyle(fontSize: 11, color: subtitleColor),
                      ),
                      Text(
                        trip.destination,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(color: Color(0xFFF1F5F9), height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(trip.travelDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.travelTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.scale_rounded,
                      size: 15,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.availableWeight} kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: 40,
            color: subtitleColor,
          ),
          const SizedBox(height: 10),
          const Text(
            'No Active Trips',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Publish a new trip to start accepting parcel delivery requests.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _navigateToCreateTrip,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Create Trip',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}