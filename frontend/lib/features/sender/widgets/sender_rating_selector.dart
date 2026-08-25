import 'package:flutter/material.dart';

/// Reusable 1–5 star rating selector component for Senders.
class SenderRatingSelector extends StatelessWidget {
  final double currentRating;
  final ValueChanged<double>? onRatingChanged;
  final bool readOnly;

  const SenderRatingSelector({
    super.key,
    required this.currentRating,
    this.onRatingChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = Colors.amber[700]!;
    final inactiveColor = Colors.grey[400]!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = currentRating >= starIndex;

            return InkWell(
              onTap: readOnly ? null : () => onRatingChanged?.call(starIndex.toDouble()),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color: isFilled ? activeColor : inactiveColor,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          currentRating > 0
              ? 'Rating: ${currentRating.toInt()}/5'
              : 'Tap stars to rate',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: currentRating > 0 ? activeColor : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
