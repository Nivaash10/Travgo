import 'package:flutter/material.dart';
import 'rating_colors.dart';
import '../models/rating_models.dart';

/// Person 5 — Average rating + review list for a traveller.
/// Seeded with dummy data so it's not empty in a demo.
class ReviewScreen extends StatelessWidget {
  final String travellerId;
  final String travellerName;
  final Review? newReview;

  const ReviewScreen({
    super.key,
    required this.travellerId,
    required this.travellerName,
    this.newReview,
  });

  @override
  Widget build(BuildContext context) {
    final reviews = [if (newReview != null) newReview!];
    final avg = reviews.isNotEmpty
        ? (reviews.map((r) => r.stars).reduce((a, b) => a + b) / reviews.length)
        : 0.0;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Reviews', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(travellerName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
                        const SizedBox(height: 4),
                        Text('${reviews.length} reviews', style: const TextStyle(fontSize: 12, color: kMuted)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(avg.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: kAccent, size: 22),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 36, color: kMuted),
                    SizedBox(height: 10),
                    Text(
                      'No reviews yet',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Reviews submitted for this user will appear here.',
                      style: TextStyle(fontSize: 12, color: kMuted),
                    ),
                  ],
                ),
              )
            else
              for (final r in reviews) _reviewCard(r),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text(
                  'Done • Return to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(Review r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              r.reviewerName.isNotEmpty ? r.reviewerName[0] : '?',
              style: const TextStyle(color: kAccent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(r.reviewerName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
                    ),
                    Text(r.date, style: const TextStyle(fontSize: 11, color: kMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < r.stars ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 14,
                    color: kAccent,
                  )),
                ),
                if (r.text != null) ...[
                  const SizedBox(height: 6),
                  Text(r.text!, style: const TextStyle(fontSize: 13, color: kText)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}