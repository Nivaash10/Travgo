/// Parcel Status Card — Phase 1
///
/// Reusable mobile card that displays parcel details and status.
/// Placeholder — GPS/live data will be wired in Phase 2.
library;

import 'package:flutter/material.dart';
import '../../otp/widgets/travgo_theme.dart';

/// Data model passed into the card.
class ParcelCardData {
  final String parcelId;
  final String origin;
  final String destination;
  final ParcelStatusUi status;
  final String lastUpdated;

  const ParcelCardData({
    required this.parcelId,
    required this.origin,
    required this.destination,
    required this.status,
    required this.lastUpdated,
  });
}

class ParcelStatusCard extends StatelessWidget {
  const ParcelStatusCard({super.key, required this.data});

  final ParcelCardData data;

  @override
  Widget build(BuildContext context) {
    return TravgoCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TravgoColors.primaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: TravgoColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Parcel', style: TravgoText.caption),
                  Text(
                    '#${data.parcelId}',
                    style: const TextStyle(
                      color: TravgoColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ParcelStatusChip(status: data.status),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: TravgoColors.divider, height: 1),
          const SizedBox(height: 14),

          // ── Route row ───────────────────────────────────────────────────
          _RouteStrip(origin: data.origin, destination: data.destination),

          const SizedBox(height: 16),
          const Divider(color: TravgoColors.divider, height: 1),
          const SizedBox(height: 12),

          // ── Footer ──────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: TravgoColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                'Last updated ${data.lastUpdated}',
                style: TravgoText.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Route strip helper ───────────────────────────────────────────────────────

class _RouteStrip extends StatelessWidget {
  const _RouteStrip({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Origin
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FROM', style: TravgoText.caption),
              const SizedBox(height: 3),
              Text(origin, style: TravgoText.bodyBold,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),

        // Middle arrow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 2,
                    color: TravgoColors.border,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: TravgoColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: TravgoColors.primary, size: 16),
                  Container(
                    width: 20,
                    height: 2,
                    color: TravgoColors.border,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Destination
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('TO', style: TravgoText.caption),
              const SizedBox(height: 3),
              Text(destination, style: TravgoText.bodyBold,
                  overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
            ],
          ),
        ),
      ],
    );
  }
}
