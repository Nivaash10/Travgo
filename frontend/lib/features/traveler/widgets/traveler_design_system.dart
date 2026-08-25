import 'package:flutter/material.dart';

/// TRAVGO Traveler Design System & Tokens
class TravelerDesignSystem {
  // Brand Colors
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDarkColor = Color(0xFF1D4ED8);
  static const Color secondaryColor = Color(0xFF14B8A6); // Teal
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color successColor = Color(0xFF10B981); // Emerald Green
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color textColor = Color(0xFF1E293B); // Slate Dark
  static const Color subtitleColor = Color(0xFF64748B); // Slate Medium
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color surfaceLightColor = Color(0xFFF8FAFC);

  // Spacing System
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;
  static const double spaceHUGE = 32.0;

  // Card Radius
  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;

  // Standard Card BoxShadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get brandShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // Helper Widget for Status Chip
  static Widget buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = successColor;
        bgColor = const Color(0xFFECFDF5);
        break;
      case 'UPCOMING':
        color = primaryColor;
        bgColor = const Color(0xFFEFF6FF);
        break;
      case 'COMPLETED':
        color = const Color(0xFF059669);
        bgColor = const Color(0xFFF0FDF4);
        break;
      case 'ACCEPTED':
        color = successColor;
        bgColor = const Color(0xFFECFDF5);
        break;
      case 'REJECTED':
      case 'CANCELLED':
        color = errorColor;
        bgColor = const Color(0xFFFEF2F2);
        break;
      case 'PENDING':
      default:
        color = accentColor;
        bgColor = const Color(0xFFFEF3C7);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // TRAVGO Signature Route Graphic Component
  static Widget buildRouteGraphic({
    required String source,
    required String destination,
    String? dateAndTime,
    double height = 40,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 3),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: height,
              color: primaryColor.withValues(alpha: 0.3),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              if (dateAndTime != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateAndTime,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(height: height - 16),
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
