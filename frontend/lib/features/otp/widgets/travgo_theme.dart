/// TRAVGO Shared Theme — Person 4 UI Design System
///
/// Light, mobile-first design tokens used across OTP and Tracking screens.
/// Do NOT modify business logic here — UI constants only.
library;

import 'package:flutter/material.dart';

// ─── Brand Colours ────────────────────────────────────────────────────────────

class TravgoColors {
  TravgoColors._();

  // Primary blue palette
  static const Color primary      = Color(0xFF1A73E8); // TRAVGO blue
  static const Color primaryLight = Color(0xFF4A9EFF); // lighter blue
  static const Color primaryBg    = Color(0xFFE8F0FE); // very light blue bg

  // Backgrounds
  static const Color scaffoldBg   = Color(0xFFF5F7FC); // main screen bg
  static const Color cardBg       = Color(0xFFFFFFFF); // card surface
  static const Color inputBg      = Color(0xFFF0F4FF); // OTP input bg

  // Text
  static const Color textPrimary   = Color(0xFF0D1B3E); // dark navy
  static const Color textSecondary = Color(0xFF6B7A99); // muted slate
  static const Color textHint      = Color(0xFFB0BCDA);

  // Status
  static const Color success       = Color(0xFF16A34A);
  static const Color successBg     = Color(0xFFDCFCE7);
  static const Color successBorder = Color(0xFF86EFAC);

  static const Color warning       = Color(0xFFD97706);
  static const Color warningBg     = Color(0xFFFEF3C7);

  static const Color error         = Color(0xFFDC2626);
  static const Color errorBg       = Color(0xFFFEE2E2);
  static const Color errorBorder   = Color(0xFFFCA5A5);

  static const Color info          = Color(0xFF0369A1);
  static const Color infoBg        = Color(0xFFE0F2FE);
  static const Color infoBorder    = Color(0xFF7DD3FC);

  static const Color purple        = Color(0xFF7C3AED);
  static const Color purpleBg      = Color(0xFFEDE9FE);

  // Borders & dividers
  static const Color border        = Color(0xFFDEE5F5);
  static const Color divider       = Color(0xFFEBF0FA);

  // AppBar
  static const Color appBarBg      = Color(0xFFFFFFFF);
  static const Color appBarFg      = Color(0xFF0D1B3E);
}

// ─── Typography ───────────────────────────────────────────────────────────────

class TravgoText {
  TravgoText._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: TravgoColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: TravgoColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: TravgoColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: TravgoColors.textPrimary,
  );

  static const TextStyle coordinates = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: TravgoColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: TravgoColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: TravgoColors.textSecondary,
    letterSpacing: 0.2,
  );
}


// ─── Shared Widgets ───────────────────────────────────────────────────────────

/// Standard white card used across OTP and Tracking screens.
class TravgoCard extends StatelessWidget {
  const TravgoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: TravgoColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TravgoColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// TRAVGO primary button — full width, 52 px tall, overflow-safe.
class TravgoPrimaryButton extends StatelessWidget {
  const TravgoPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = TravgoColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: TravgoColors.border,
          disabledForegroundColor: TravgoColors.textSecondary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard TRAVGO AppBar — white, back arrow, title left-aligned.
PreferredSizeWidget travgoAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    backgroundColor: TravgoColors.appBarBg,
    foregroundColor: TravgoColors.appBarFg,
    elevation: 0,
    titleSpacing: 0,
    scrolledUnderElevation: 1,
    shadowColor: TravgoColors.border,
    centerTitle: false,
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: TravgoColors.textPrimary,
      ),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: TravgoColors.border, height: 1),
    ),
  );
}

/// Parcel status pill/chip.
class ParcelStatusChip extends StatelessWidget {
  const ParcelStatusChip({super.key, required this.status});

  final ParcelStatusUi status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: status.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              style: TextStyle(
                color: status.dotColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ParcelStatusUi {
  final String label;
  final Color bgColor;
  final Color dotColor;

  const ParcelStatusUi({
    required this.label,
    required this.bgColor,
    required this.dotColor,
  });

  static const paymentConfirmed = ParcelStatusUi(
    label: 'PAYMENT CONFIRMED',
    bgColor: TravgoColors.infoBg,
    dotColor: TravgoColors.info,
  );
  static const pickedUp = ParcelStatusUi(
    label: 'PICKED UP',
    bgColor: TravgoColors.primaryBg,
    dotColor: TravgoColors.primary,
  );
  static const inTransit = ParcelStatusUi(
    label: 'IN TRANSIT',
    bgColor: TravgoColors.primaryBg,
    dotColor: TravgoColors.primary,
  );
  static const destinationReached = ParcelStatusUi(
    label: 'DESTINATION REACHED',
    bgColor: TravgoColors.successBg,
    dotColor: TravgoColors.success,
  );
  static const delivered = ParcelStatusUi(
    label: 'DELIVERED',
    bgColor: TravgoColors.successBg,
    dotColor: TravgoColors.success,
  );
}
