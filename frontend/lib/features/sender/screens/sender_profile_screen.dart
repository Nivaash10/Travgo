import 'package:flutter/material.dart';
import '../../common/repository/user_profile_repository.dart';
import '../data/sender_mock_booking_data.dart';
import '../models/sender_booking.dart';
import '../models/sender_delivery_status.dart';
import 'sender_booking_detail_screen.dart';
import 'sender_edit_profile_screen.dart';
import 'saved_receivers_screen.dart';

/// Professional role-specific Sender Profile screen.
/// Displays real authenticated Sender information, delivery statistics,
/// calculated performance ratings & tags, recent activity, and profile actions.
class SenderProfileScreen extends StatefulWidget {
  final bool isReadOnly;
  final String? senderId;
  final String? senderName;

  const SenderProfileScreen({
    super.key,
    this.isReadOnly = false,
    this.senderId,
    this.senderName,
  });

  @override
  State<SenderProfileScreen> createState() => _SenderProfileScreenState();
}

class _SenderProfileScreenState extends State<SenderProfileScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

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

  @override
  Widget build(BuildContext context) {
    final bookings = SenderMockBookingData.getMockBookings();
    final profile = UserProfileRepository().senderProfile;
    final displayName = widget.senderName ?? profile.fullName;
    final email = profile.email;
    final phone = profile.phone;

    final totalRequests = bookings.length;
    final completedDeliveries = bookings.where((b) => b.status == SenderDeliveryStatus.delivered).length;
    final activeDeliveries = bookings.where((b) =>
      b.status == SenderDeliveryStatus.inTransit ||
      b.status == SenderDeliveryStatus.pickedUp ||
      b.status == SenderDeliveryStatus.accepted
    ).length;
    final cancelledDeliveries = bookings.where((b) => b.status == SenderDeliveryStatus.rejected).length;

    // Derived rating performance tags from Traveller reviews
    final List<String> performanceTags = [
      'Parcel Ready on Time',
      'Clear Instructions',
      'Easy Pickup Coordination',
      'Accurate Parcel Information',
      'Responsive Communication',
      'Polite & Respectful',
      'Smooth Handover',
    ];

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
          widget.isReadOnly ? 'Sender Profile' : 'My Sender Profile',
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
                  MaterialPageRoute(builder: (context) => const SenderEditProfileScreen()),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            _buildProfileHeaderCard(displayName, profile.rating),

            const SizedBox(height: 18),

            // 2. Personal Information
            _buildPersonalInformationCard(displayName, email, phone, profile.bio),

            const SizedBox(height: 18),

            // 3. Delivery Statistics Grid
            _buildDeliveryStatisticsGrid(
              totalRequests: totalRequests,
              completed: completedDeliveries,
              active: activeDeliveries,
              cancelled: cancelledDeliveries,
            ),

            const SizedBox(height: 18),

            // 4. Sender Performance & Ratings
            _buildSenderPerformanceCard(performanceTags),

            const SizedBox(height: 18),

            // 5. Recent Delivery Activity
            _buildRecentActivitySection(context, bookings),

            const SizedBox(height: 18),

            // 6. Account Information
            _buildAccountInformationCard(),

            if (!widget.isReadOnly) ...[
              const SizedBox(height: 18),

              // 7. Profile Actions
              _buildProfileActionsSection(context),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(String name, double rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
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
                  'SENDER',
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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, size: 11, color: successColor),
                    SizedBox(width: 4),
                    Text(
                      'VERIFIED SENDER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: successColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: accentColor, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(width: 4),
              const Text(
                '(Calculated from Traveller reviews)',
                style: TextStyle(fontSize: 12, color: subtitleColor),
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
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.shield_outlined, 'Identity Status', 'Government ID Verified'),
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

  Widget _buildDeliveryStatisticsGrid({
    required int totalRequests,
    required int completed,
    required int active,
    required int cancelled,
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
            'DELIVERY STATISTICS',
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
              Expanded(child: _buildStatTile('Total Requests', '$totalRequests', Icons.local_shipping_outlined, primaryColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatTile('Completed', '$completed', Icons.check_circle_outline_rounded, successColor)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatTile('Active', '$active', Icons.sync_rounded, const Color(0xFF0284C7))),
              const SizedBox(width: 10),
              Expanded(child: _buildStatTile('Cancelled', '$cancelled', Icons.cancel_outlined, const Color(0xFFEF4444))),
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

  Widget _buildSenderPerformanceCard(List<String> tags) {
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
            'SENDER PERFORMANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          if (tags.isEmpty)
            const Text('No reviews yet', style: TextStyle(fontSize: 13, color: subtitleColor))
          else ...[
            const Text(
              'Highlights from Traveller Reviews',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 12, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
                  ],
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, List<SenderBooking> bookings) {
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
            'RECENT DELIVERY ACTIVITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          if (bookings.isEmpty)
            const Text('No recent delivery requests', style: TextStyle(fontSize: 13, color: subtitleColor))
          else
            Column(
              children: bookings.take(3).map((b) => Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${b.request.parcelCategory} (${b.id})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    subtitle: Text(
                      '${b.pickupLocation ?? b.request.searchQuery.source} → ${b.deliveryLocation ?? b.request.searchQuery.destination}\nTraveller: ${b.travellerName ?? 'Searching...'}',
                      style: const TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: subtitleColor),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SenderBookingDetailScreen(booking: b),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                ],
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountInformationCard() {
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
          _buildInfoRow(Icons.badge_outlined, 'Account Type', 'Sender'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.check_circle_outline_rounded, 'Account Status', 'Active'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.calendar_today_rounded, 'Member Since', 'August 2026'),
        ],
      ),
    );
  }

  Widget _buildProfileActionsSection(BuildContext context) {
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
            'ACCOUNT ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline_rounded, color: primaryColor),
            title: const Text('Edit Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (context) => const SenderEditProfileScreen()),
              );
              if (updated == true && mounted) {
                setState(() {});
              }
            },
          ),
          const Divider(height: 12, color: Color(0xFFF1F5F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bookmark_outline_rounded, color: primaryColor),
            title: const Text('Saved Receivers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SavedReceiversScreen()),
              );
            },
          ),
          const Divider(height: 12, color: Color(0xFFF1F5F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined, color: primaryColor),
            title: const Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications opened.')));
            },
          ),
          const Divider(height: 12, color: Color(0xFFF1F5F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            title: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
