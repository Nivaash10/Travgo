import 'package:flutter/material.dart';
import '../models/sender_delivery_rating.dart';
import '../widgets/sender_rating_badge.dart';
import 'my_bookings_screen.dart';

/// Screen displaying submission confirmation for Sender delivery feedback.
class SenderFeedbackConfirmationScreen extends StatelessWidget {
  final SenderDeliveryRating rating;

  const SenderFeedbackConfirmationScreen({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Submitted'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Thank You!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback has been submitted successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),

              // Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _DetailLine(label: 'Traveller', value: rating.travellerName),
                      if (rating.route != null) ...[
                        const Divider(height: 16),
                        _DetailLine(label: 'Route', value: rating.route!),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rating', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          SenderRatingBadge(rating: rating.rating),
                        ],
                      ),
                      if (rating.feedback != null && rating.feedback!.isNotEmpty) ...[
                        const Divider(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Feedback:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(
                                '"${rating.feedback!}"',
                                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MyBookingsScreen(),
                    ),
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to My Bookings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
