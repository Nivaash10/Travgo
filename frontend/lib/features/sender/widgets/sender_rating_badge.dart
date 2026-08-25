import 'package:flutter/material.dart';

/// Reusable rating badge widget displaying "â˜… 4.5" or "Not Rated".
class SenderRatingBadge extends StatelessWidget {
  final double rating;
  final bool isSubmitted;

  const SenderRatingBadge({
    super.key,
    required this.rating,
    this.isSubmitted = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasRating = isSubmitted && rating > 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasRating ? Colors.amber[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRating ? Colors.amber[700]! : Colors.grey[400]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasRating ? Icons.star : Icons.star_border,
            size: 14,
            color: hasRating ? Colors.amber[800] : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            hasRating ? 'â˜… ${rating.toStringAsFixed(1)}' : 'Not Rated',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasRating ? Colors.amber[900] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
