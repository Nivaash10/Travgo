import 'package:flutter/material.dart';
import '../models/traveler_trip.dart';
import '../repository/parcel_request_repository.dart';
import '../repository/traveler_trip_repository.dart';
import '../widgets/journey_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/request_preview_card.dart';
import '../widgets/traveler_bottom_nav.dart';
import '../widgets/traveler_header.dart';
import '../widgets/verification_status_card.dart';
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
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);

  int _currentBottomNavIndex = 0;

  void _showFeatureSnackBar(BuildContext context, String featureTitle) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureTitle selected'),
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
    if (mounted) {
      setState(() {
        _currentBottomNavIndex = 0;
      });
    }
  }

  Future<void> _navigateToTripDetails(TravelerTrip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip)),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _navigateToIncomingRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncomingRequestsScreen()),
    );
    if (mounted) {
      setState(() {
        _currentBottomNavIndex = 0;
      });
    }
  }

  Future<void> _navigateToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelerProfileScreen()),
    );
    if (mounted) {
      setState(() {
        _currentBottomNavIndex = 0;
      });
    }
  }

  Future<void> _navigateToAadhaarVerification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AadhaarVerificationScreen()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      setState(() {
        _currentBottomNavIndex = 0;
      });
    } else if (index == 1) {
      _navigateToMyTrips();
    } else if (index == 2) {
      _navigateToIncomingRequests();
    } else if (index == 3) {
      _navigateToProfile();
    }
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning, Traveler';
    } else if (hour < 17) {
      return 'Good afternoon, Traveler';
    } else {
      return 'Good evening, Traveler';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripRepo = TravelerTripRepository();
    final requestRepo = ParcelRequestRepository();

    final isVerified = tripRepo.isVerified;
    final activeTrip = tripRepo.activeTrip;
    final tripCount = tripRepo.tripCount;
    final requestCount = requestRepo.getTotalRequestCount();
    final allRequests = requestRepo.requests;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1. Top Header
          TravelerHeader(
            onProfileTap: _navigateToProfile,
            onNotificationTap: () => _showFeatureSnackBar(context, 'Notifications'),
          ),

          // Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Traveler Greeting / Identity Section
                  Text(
                    _getGreetingText(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Ready for your next journey?',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Verification Status Card
                  VerificationStatusCard(
                    isVerified: isVerified,
                    onVerifyTap: _navigateToAadhaarVerification,
                  ),

                  const SizedBox(height: 20),

                  // 4. Journey Visual Card
                  JourneyCard(
                    activeTrip: activeTrip,
                    onCreateTripTap: _navigateToCreateTrip,
                    onTripTap: _navigateToTripDetails,
                  ),

                  const SizedBox(height: 24),

                  // 5. Quick Actions Section Title & Grid
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QuickActionGrid(
                    onCreateTripTap: _navigateToCreateTrip,
                    onMyTripsTap: _navigateToMyTrips,
                    onRequestsTap: _navigateToIncomingRequests,
                    onProfileTap: _navigateToProfile,
                    tripCount: tripCount,
                    requestCount: requestCount,
                  ),

                  const SizedBox(height: 24),

                  // 6. Active Trip Section (if present)
                  if (activeTrip != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Trip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToMyTrips,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View All →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildActiveTripCard(context, activeTrip),
                    const SizedBox(height: 24),
                  ],

                  // 7. Incoming Request Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Parcel Delivery Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (allRequests.isNotEmpty)
                        TextButton(
                          onPressed: _navigateToIncomingRequests,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'See Details →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RequestPreviewCard(
                    requests: allRequests,
                    onViewRequestsTap: _navigateToIncomingRequests,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      // 8. Integrated Bottom Navigation Bar
      bottomNavigationBar: TravelerBottomNav(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildActiveTripCard(BuildContext context, TravelerTrip trip) {
    return InkWell(
      onTap: () => _navigateToTripDetails(trip),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.05),
              blurRadius: 10,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ACTIVE JOURNEY',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${trip.price.toInt()} / parcel',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

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
                  size: 18,
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

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trip.availableWeight.toInt()} kg capacity available',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View Trip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}