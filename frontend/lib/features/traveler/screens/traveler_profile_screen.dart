import 'package:flutter/material.dart';
import '../repository/parcel_request_repository.dart';
import '../repository/traveler_trip_repository.dart';
import 'aadhaar_verification_screen.dart';

class TravelerProfileScreen extends StatefulWidget {
  const TravelerProfileScreen({super.key});

  @override
  State<TravelerProfileScreen> createState() => _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends State<TravelerProfileScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
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

  Future<void> _navigateToAadhaarVerification() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AadhaarVerificationScreen()),
    );

    if (result == true || TravelerTripRepository().isVerified) {
      setState(() {});
    }
  }

  void _showPhotoSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: cardColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
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
                        content: const Text(
                          'cloud storage upload to be implemented.',
                        ),
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
    final requestRepo = ParcelRequestRepository();

    final totalTrips = tripRepo.tripCount;
    final activeTrips = tripRepo.activeTrip != null ? 1 : 0;
    final acceptedDeliveries =
        requestRepo.requests.where((r) => r.status == 'ACCEPTED').length;

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
        title: const Text(
          'Traveler Profile',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Profile Header & Photo Card
            _buildProfileHeaderCard(),

            const SizedBox(height: 16),

            // 2. Identity Verification Card
            _buildIdentityVerificationCard(),

            const SizedBox(height: 16),

            // 3. Rating Placeholder Card
            _buildRatingCard(),

            const SizedBox(height: 16),

            // 4. Travel Statistics Card
            _buildStatisticsCard(
              totalTrips: totalTrips,
              activeTrips: activeTrips,
              acceptedDeliveries: acceptedDeliveries,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    final isVerified = TravelerTripRepository().isVerified;

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
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  _selectedAvatarIcon,
                  color: primaryColor,
                  size: 48,
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: successColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Upload Photo Button
          OutlinedButton.icon(
            onPressed: _showPhotoSelectionSheet,
            icon: const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text(
              'Upload Photo',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Text(
            'Alex Morgan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'alex.morgan@travgo.com',
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '+91 98765 43210',
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityVerificationCard() {
    final isVerified = TravelerTripRepository().isVerified;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identity Verification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVerified
                ? 'Your Aadhaar identity has been verified.'
                : 'Verify your Aadhaar to become a verified TRAVGO traveler.',
            style: const TextStyle(
              fontSize: 13,
              color: subtitleColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Status & Button Row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isVerified
                  ? successColor.withValues(alpha: 0.08)
                  : accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVerified ? successColor : accentColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isVerified
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: isVerified ? successColor : accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVerified ? '✓ Verified Traveler' : '⚠ Not Verified',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isVerified ? successColor : const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isVerified
                            ? 'Aadhaar Identity Verified'
                            : 'Aadhaar Verification Pending',
                        style: const TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isVerified)
                  ElevatedButton(
                    onPressed: _navigateToAadhaarVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Verify Aadhaar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 24),

          // Phone Verification Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Phone Verification',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: successColor,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Phone Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.star_rounded, color: accentColor, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '(5 ratings)',
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Rating component integrated by Person 5',
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard({
    required int totalTrips,
    required int activeTrips,
    required int acceptedDeliveries,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Travel Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  label: 'Trips Published',
                  value: '$totalTrips',
                  icon: Icons.directions_bus_rounded,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  label: 'Active Trips',
                  value: '$activeTrips',
                  icon: Icons.route_rounded,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  label: 'Deliveries',
                  value: '$acceptedDeliveries',
                  icon: Icons.markunread_mailbox_outlined,
                  color: successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
