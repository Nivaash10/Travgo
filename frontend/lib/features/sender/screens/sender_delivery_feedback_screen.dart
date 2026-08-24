import 'package:flutter/material.dart';
import '../data/sender_mock_delivery_rating.dart';
import '../models/sender_delivery_rating.dart';
import '../widgets/sender_rating_badge.dart';
import '../widgets/sender_rating_selector.dart';
import 'sender_feedback_confirmation_screen.dart';

/// Screen allowing Senders to rate travellers and submit written feedback after delivery completion.
class SenderDeliveryFeedbackScreen extends StatefulWidget {
  final SenderDeliveryRating? ratingData;
  final String? bookingId;
  final String? requestId;
  final String? travellerName;
  final String? route;

  const SenderDeliveryFeedbackScreen({
    super.key,
    this.ratingData,
    this.bookingId,
    this.requestId,
    this.travellerName,
    this.route,
  });

  @override
  State<SenderDeliveryFeedbackScreen> createState() =>
      _SenderDeliveryFeedbackScreenState();
}

class _SenderDeliveryFeedbackScreenState
    extends State<SenderDeliveryFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  late SenderDeliveryRating _rating;

  @override
  void initState() {
    super.initState();
    if (widget.ratingData != null) {
      _rating = widget.ratingData!;
    } else {
      final bId = widget.bookingId ?? 'BKG-105';
      _rating = SenderMockDeliveryRatingData.getRatingForBooking(
        bId,
        travellerName: widget.travellerName,
        route: widget.route,
      );
    }

    if (_rating.feedback != null) {
      _feedbackController.text = _rating.feedback!;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _onRatingChanged(double newRating) {
    if (_rating.isSubmitted) return;
    setState(() {
      _rating = _rating.copyWith(rating: newRating);
    });
  }

  void _submitFeedback() {
    if (_rating.isSubmitted) return;
    if (_rating.rating < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating between 1 and 5.')),
      );
      return;
    }

    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback cannot exceed 200 characters.')),
      );
      return;
    }

    final submittedRating = _rating.copyWith(
      feedback: feedbackText.isNotEmpty ? feedbackText : null,
      submittedAt: DateTime.now(),
      isSubmitted: true,
    );

    SenderMockDeliveryRatingData.saveRating(submittedRating);

    setState(() {
      _rating = submittedRating;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SenderFeedbackConfirmationScreen(
          rating: submittedRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAlreadySubmitted = _rating.isSubmitted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Delivery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Delivery Completed Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DELIVERY COMPLETED',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (isAlreadySubmitted)
                              SenderRatingBadge(
                                rating: _rating.rating,
                                isSubmitted: true,
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 20),
                        _SummaryRow(label: 'Traveller', value: _rating.travellerName),
                        _SummaryRow(
                          label: 'Route',
                          value: _rating.route ?? 'Coimbatore → Chennai',
                        ),
                        _SummaryRow(label: 'Booking ID', value: _rating.bookingId),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (isAlreadySubmitted) ...[
                  // Read-Only Submitted Feedback State
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.stars_rounded, size: 48, color: Colors.amber[800]),
                        const SizedBox(height: 12),
                        Text(
                          'Feedback Already Submitted',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SenderRatingSelector(
                          currentRating: _rating.rating,
                          readOnly: true,
                        ),
                        if (_rating.feedback != null && _rating.feedback!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            '"${_rating.feedback!}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                ] else ...[
                  // Rating Section
                  Text(
                    'How was your delivery experience?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SenderRatingSelector(
                    currentRating: _rating.rating,
                    onRatingChanged: _onRatingChanged,
                    readOnly: false,
                  ),
                  const SizedBox(height: 28),

                  // Optional Feedback Input
                  Text(
                    'Share your feedback (Optional)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Tell us how traveller ${_rating.travellerName} performed...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _rating.rating >= 1.0 ? _submitFeedback : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
