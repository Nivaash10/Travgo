import 'package:flutter/material.dart';

class QuickActionGrid extends StatelessWidget {
  final VoidCallback onCreateTripTap;
  final VoidCallback onMyTripsTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onProfileTap;
  final int tripCount;
  final int requestCount;

  const QuickActionGrid({
    super.key,
    required this.onCreateTripTap,
    required this.onMyTripsTap,
    required this.onRequestsTap,
    required this.onProfileTap,
    required this.tripCount,
    required this.requestCount,
  });

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Primary Hero Action: + Create Trip
            Expanded(
              child: _QuickActionButton(
                onTap: onCreateTripTap,
                icon: Icons.add_rounded,
                title: 'Create Trip',
                subtitle: 'Publish route',
                isPrimary: true,
                badgeText: 'HOT',
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),

            // My Trips Action
            Expanded(
              child: _QuickActionButton(
                onTap: onMyTripsTap,
                icon: Icons.directions_bus_rounded,
                title: 'My Trips',
                subtitle: '$tripCount published',
                isPrimary: false,
                iconColor: primaryColor,
                iconBgColor: const Color(0xFFEFF6FF),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12, height: 12),
        Row(
          children: [
            // Parcel Requests Action
            Expanded(
              child: _QuickActionButton(
                onTap: onRequestsTap,
                icon: Icons.inventory_2_rounded,
                title: 'Requests',
                subtitle: '$requestCount pending',
                isPrimary: false,
                iconColor: secondaryColor,
                iconBgColor: const Color(0xFFCCFBF1),
                badgeText: requestCount > 0 ? '$requestCount' : null,
              ),
            ),
            const SizedBox(width: 12),

            // Profile Action
            Expanded(
              child: _QuickActionButton(
                onTap: onProfileTap,
                icon: Icons.person_rounded,
                title: 'Profile',
                subtitle: 'Manage account',
                isPrimary: false,
                iconColor: accentColor,
                iconBgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? primaryColor;
  final String? badgeText;

  const _QuickActionButton({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    this.iconColor,
    this.iconBgColor,
    this.primaryColor,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      final brandColor = primaryColor ?? const Color(0xFF2563EB);
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [brandColor, const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: brandColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBgColor ?? const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor ?? const Color(0xFF1E293B), size: 20),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
