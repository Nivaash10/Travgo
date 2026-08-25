import 'package:flutter/material.dart';
import '../data/sender_mock_delivery_rating.dart';
import '../models/sender_delivery_rating.dart';
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

  final List<String> _availableTags = [
    'Punctual',
    'Careful Handling',
    'Great Communication',
    'Polite & Friendly',
    'Fast Highway Travel',
    'Clean Vehicle Boot',
  ];
  final List<String> _selectedTags = [
    'Punctual',
    'Careful Handling',
    'Great Communication',
  ];

  int _selectedTip = 20;
  bool _isSubmitting = false;

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

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submitFeedback() {
    if (_rating.isSubmitted || _isSubmitting) return;
    if (_rating.rating < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating between 1 and 5.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final feedbackText = _feedbackController.text.trim();
    final submittedRating = _rating.copyWith(
      feedback: feedbackText.isNotEmpty ? feedbackText : null,
      submittedAt: DateTime.now(),
      isSubmitted: true,
    );

    SenderMockDeliveryRatingData.saveRating(submittedRating);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 32,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your feedback helps keep the TRAVGO peer delivery community safe and reliable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                SenderFeedbackConfirmationScreen(rating: submittedRating),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadySubmitted = _rating.isSubmitted;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate & Review')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Traveller Card with Avatar & Interactive Stars
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFFE2E8F0),
                              child: Text(
                                _rating.travellerName.isNotEmpty
                                    ? _rating.travellerName[0].toUpperCase()
                                    : 'T',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _rating.travellerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Delivered: ${_rating.route ?? "Coimbatore â†’ Chennai"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 5 Star Rating Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starNum = index + 1;
                                final isSelected = _rating.rating >= starNum;
                                return InkWell(
                                  onTap: isAlreadySubmitted
                                      ? null
                                      : () => _onRatingChanged(
                                          starNum.toDouble(),
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 36,
                                      color: isSelected
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!isAlreadySubmitted) ...[
                        // 2. Tag Selection Card ("What went well?")
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WHAT WENT WELL?',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableTags.map((tag) {
                                  final isSelected = _selectedTags.contains(
                                    tag,
                                  );
                                  return InkWell(
                                    onTap: () => _toggleTag(tag),
                                    borderRadius: BorderRadius.circular(20),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFEFF6FF)
                                            : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFBFDBFE)
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            tag,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? const Color(0xFF1D4ED8)
                                                  : const Color(0xFF475569),
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Color(0xFF1D4ED8),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Review Feedback Text Card
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FEEDBACK & COMMENTS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _feedbackController,
                                maxLines: 3,
                                maxLength: 200,
                                decoration: InputDecoration(
                                  hintText:
                                      'Share details of your experience...',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.all(12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Tip Selection Card (Optional)
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ADD A TIP FOR TRAVELLER (OPTIONAL)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [0, 20, 50, 100].map((amount) {
                                  final isSelected = _selectedTip == amount;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: InkWell(
                                        onTap: () => setState(
                                          () => _selectedTip = amount,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF2563EB)
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Text(
                                            amount == 0 ? 'No Tip' : 'â‚¹$amount',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF334155),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Floating Bottom Submit Button
            if (!isAlreadySubmitted)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_rating.rating >= 1.0 && !_isSubmitting)
                        ? _submitFeedback
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Submit Review (${_rating.rating.toInt()} Stars)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
