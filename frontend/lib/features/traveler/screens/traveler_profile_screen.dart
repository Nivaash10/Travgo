import 'package:flutter/material.dart';
import '../../common/repository/user_profile_repository.dart';
import '../../sender/models/sender_traveller_match.dart';
import '../repository/traveler_trip_repository.dart';
import 'aadhaar_verification_screen.dart';
import 'traveler_edit_profile_screen.dart';

/// Professional role-specific Traveller Profile screen.
/// Supports both self-view (editable presets & verification) and peer-view
/// (opened by a Sender during Step 4 matching with a sticky [ Select Traveller ] CTA).
class TravelerProfileScreen extends StatefulWidget {
  final bool isReadOnly;
  final SenderTravellerMatch? match;
  final bool canSelect;
  final ValueChanged<SenderTravellerMatch>? onSelectTraveller;

  const TravelerProfileScreen({
    super.key,
    this.isReadOnly = false,
    this.match,
    this.canSelect = false,
    this.onSelectTraveller,
  });

  @override
  State<TravelerProfileScreen> createState() => _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends State<TravelerProfileScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final List<IconData> _avatarPresets = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.account_circle_rounded,
    Icons.person_pin_rounded,
    Icons.emoji_people_rounded,
  ];

  IconData _selectedAvatarIcon = Icons.person_rounded;

  @override
  void initState() {
    super.initState();
    UserProfileRepository().addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    UserProfileRepository().removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _navigateToAadhaarVerification() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AadhaarVerificationScreen()),
    );

    if (result == true || TravelerTripRepository().isVerified) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showPhotoSelectionSheet() {
    if (widget.isReadOnly) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Profile Avatar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose a profile avatar preset or device photo.',
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _avatarPresets.map((icon) {
                  final isSelected = icon == _selectedAvatarIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAvatarIcon = icon;
                        TravelerTripRepository().profileImagePath = icon.codePoint.toString();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Profile photo updated successfully.'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.15)
                            : backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: isSelected ? primaryColor : subtitleColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Device gallery photo upload ready.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripRepo = TravelerTripRepository();
    final profile = UserProfileRepository().travellerProfile;

    final travelerName = widget.match?.travellerName ?? profile.fullName;
    final isVerified = widget.match?.isVerified ?? tripRepo.isVerified;
    final rating = widget.match?.rating ?? profile.rating;
    final totalTrips = tripRepo.tripCount > 0 ? tripRepo.tripCount : profile.totalTrips;
    final activeTrip = tripRepo.activeTrip;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isReadOnly ? 'Traveller Profile' : 'My Traveller Profile',
          style: const TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: textColor),
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (context) => const TravelerEditProfileScreen()),
                );
                if (updated == true && mounted) {
                  setState(() {});
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Identity Profile Header Card
            _buildProfileHeaderCard(travelerName, isVerified, rating, totalTrips),

            const SizedBox(height: 18),

            // 2. Personal Information Card
            _buildPersonalInformationCard(travelerName, profile.email, profile.phone, profile.bio),

            const SizedBox(height: 18),

            // 3. Identity Verification Card (for self view)
            if (!widget.isReadOnly) ...[
              _buildIdentityVerificationCard(isVerified),
              const SizedBox(height: 18),
            ],

            // 4. Traveller Statistics Card
            _buildStatisticsCard(
              completedTrips: totalTrips,
              activeTrips: activeTrip != null ? 1 : 0,
              cancelledTrips: 0,
              successRatePct: 98,
              avgRating: rating,
            ),

            const SizedBox(height: 18),

            // 5. Traveller Performance Categories
            _buildPerformanceCategoriesCard(),

            const SizedBox(height: 18),

            // 6. Current Active Trip Card
            _buildCurrentTripCard(activeTrip, widget.match),

            const SizedBox(height: 18),

            // 7. Trip History Card
            _buildTripHistoryCard(tripRepo),

            const SizedBox(height: 18),

            // 8. Sender Reviews
            _buildSenderReviewsCard(),

            const SizedBox(height: 18),

            // 9. Account Information
            _buildAccountInformationCard(isVerified),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: (widget.canSelect && widget.match != null && widget.onSelectTraveller != null)
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onSelectTraveller!(widget.match!);
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      'Select ${widget.match!.travellerName} (₹${widget.match!.priceRupees.toStringAsFixed(0)})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProfileHeaderCard(String name, bool isVerified, double rating, int totalTrips) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isVerified ? successColor : primaryColor,
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    _selectedAvatarIcon,
                    color: primaryColor,
                    size: 46,
                  ),
                ),
              ),
              if (!widget.isReadOnly)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _showPhotoSelectionSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Text(
                  'TRAVELLER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
                      size: 11,
                      color: isVerified ? successColor : accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'VERIFIED TRAVELLER' : 'UNVERIFIED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isVerified ? successColor : const Color(0xFFD97706),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: accentColor, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.card_travel_rounded, color: primaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                '$totalTrips Completed Trips',
                style: const TextStyle(fontSize: 13, color: subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationCard(String name, String email, String phone, String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERSONAL INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.person_outline_rounded, 'Full Name', name),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.email_outlined, 'Email', email),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.phone_android_rounded, 'Phone', phone),
          if (bio.isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
            _buildInfoRow(Icons.info_outline_rounded, 'About / Bio', bio),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: subtitleColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: subtitleColor)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityVerificationCard(bool isVerified) {
    if (!isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 10),
                Text(
                  'IDENTITY NOT VERIFIED',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete Aadhaar verification to become a Verified TRAVGO Traveler.',
              style: TextStyle(fontSize: 13, color: Color(0xFF78350F)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _navigateToAadhaarVerification,
                icon: const Icon(Icons.shield_rounded, size: 18),
                label: const Text('Verify Aadhaar →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_rounded, color: successColor, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VERIFIED TRAVELLER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF065F46))),
                  Text('Government Aadhaar Identity Verified', style: TextStyle(fontSize: 12, color: Color(0xFF047857))),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatisticsCard({
    required int completedTrips,
    required int activeTrips,
    required int cancelledTrips,
    required int successRatePct,
    required double avgRating,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAVELLER STATISTICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildStatTile('Completed Trips', '$completedTrips', Icons.check_circle_outline_rounded, successColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatTile('Active Trips', '$activeTrips', Icons.sync_rounded, primaryColor)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatTile('Success Rate', '$successRatePct%', Icons.trending_up_rounded, secondaryColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatTile('Avg Rating', avgRating.toStringAsFixed(1), Icons.star_rounded, accentColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: subtitleColor)),
        ],
      ),
    );
  }

  Widget _buildPerformanceCategoriesCard() {
    final categories = [
      {'name': 'Reliability', 'score': '4.9 / 5.0'},
      {'name': 'Communication', 'score': '5.0 / 5.0'},
      {'name': 'Parcel Handling', 'score': '4.8 / 5.0'},
      {'name': 'Pickup Coordination', 'score': '4.9 / 5.0'},
      {'name': 'Delivery Coordination', 'score': '5.0 / 5.0'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAVELLER PERFORMANCE CATEGORIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: categories.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cat['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(cat['score']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTripCard(dynamic activeTrip, SenderTravellerMatch? match) {
    final routeStr = match?.route ?? (activeTrip != null ? '${activeTrip.source} → ${activeTrip.destination}' : null);
    final dateStr = match?.travelDateTime ?? (activeTrip != null ? '${activeTrip.travelDate.day}/${activeTrip.travelDate.month}' : null);
    final capacityStr = match != null ? '${match.availableCapacityKg} kg' : (activeTrip != null ? '${activeTrip.availableWeight} kg' : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT TRIP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          if (routeStr == null)
            const Text('No active trip', style: TextStyle(fontSize: 13, color: subtitleColor))
          else ...[
            Row(
              children: [
                const Icon(Icons.directions_subway_outlined, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(routeStr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: subtitleColor, size: 14),
                const SizedBox(width: 6),
                Text(dateStr ?? 'Scheduled Today', style: const TextStyle(fontSize: 12, color: subtitleColor)),
                const SizedBox(width: 16),
                const Icon(Icons.fitness_center_rounded, color: subtitleColor, size: 14),
                const SizedBox(width: 6),
                Text('Capacity: ${capacityStr ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: subtitleColor)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripHistoryCard(TravelerTripRepository repo) {
    final trips = repo.trips;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRIP HISTORY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          if (trips.isEmpty)
            const Text('No trip history', style: TextStyle(fontSize: 13, color: subtitleColor))
          else
            Column(
              children: trips.take(3).map((t) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${t.source} → ${t.destination}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 2),
                          Text('${t.travelDate.day}/${t.travelDate.month}/${t.travelDate.year} • ${t.travelTime}', style: const TextStyle(fontSize: 11, color: subtitleColor)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: successColor)),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                ],
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSenderReviewsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REVIEWS FROM SENDERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.rate_review_outlined, color: subtitleColor, size: 20),
              SizedBox(width: 8),
              Text(
                'No reviews yet',
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInformationCard(bool isVerified) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCOUNT INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.badge_outlined, 'Account Type', 'Traveller'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            isVerified ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
            'Verification Status',
            isVerified ? 'Verified Traveller' : 'Unverified',
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.check_circle_outline_rounded, 'Account Status', 'Active'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.calendar_today_rounded, 'Member Since', 'August 2026'),
        ],
      ),
    );
  }
}
