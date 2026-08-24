import 'package:flutter/material.dart';

/// Reusable Flutter-native route visualization widget showing Source -> Current -> Destination.
class SenderTrackingRoute extends StatelessWidget {
  final String source;
  final String destination;
  final String? currentLocation;
  final double progressPercentage; // 0.0 to 1.0

  const SenderTrackingRoute({
    super.key,
    required this.source,
    required this.destination,
    this.currentLocation,
    this.progressPercentage = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLoc = currentLocation ?? 'In Transit';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ROUTE PROGRESS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(progressPercentage * 100).toInt()}% completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route Indicator Line
          Stack(
            alignment: Alignment.center,
            children: [
              // Background connecting line
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Active progress line
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage.clamp(0.05, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Three node points (Source, Current, Destination)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Source Node
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.circle, size: 8, color: Colors.white),
                  ),

                  // Current Node
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.navigation, size: 14, color: Colors.white),
                  ),

                  // Destination Node
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: progressPercentage >= 1.0
                        ? theme.colorScheme.primary
                        : Colors.grey[400],
                    child: const Icon(Icons.location_on, size: 10, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Node Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FROM',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    Text(
                      source,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Current Location Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'CURRENT',
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentLoc,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Destination Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TO',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    Text(
                      destination,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
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
}
