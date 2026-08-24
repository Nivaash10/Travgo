import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_delivery_completion_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_feedback_screen.dart';
import 'package:frontend/features/sender/screens/sender_feedback_confirmation_screen.dart';

void main() {
  test('TEST 1: SenderDeliveryRating model can be created correctly', () {
    final now = DateTime.now();
    final rating = SenderDeliveryRating(
      id: 'RAT-TEST',
      requestId: 'REQ-TEST',
      bookingId: 'BKG-TEST',
      travellerName: 'Arun',
      route: 'Coimbatore → Chennai',
      rating: 4.0,
      feedback: 'Great service!',
      submittedAt: now,
      isSubmitted: false,
    );

    expect(rating.id, equals('RAT-TEST'));
    expect(rating.bookingId, equals('BKG-TEST'));
    expect(rating.travellerName, equals('Arun'));
    expect(rating.rating, equals(4.0));
    expect(rating.feedback, equals('Great service!'));
    expect(rating.isValidRating, isTrue);
  });

  test('TEST 2: copyWith() correctly updates rating/feedback/submission state', () {
    final now = DateTime.now();
    final rating = SenderDeliveryRating(
      id: 'RAT-TEST',
      requestId: 'REQ-TEST',
      bookingId: 'BKG-TEST',
      travellerName: 'Arun',
      submittedAt: now,
    );

    final updated = rating.copyWith(
      rating: 5.0,
      feedback: 'Outstanding!',
      isSubmitted: true,
    );

    expect(updated.rating, equals(5.0));
    expect(updated.feedback, equals('Outstanding!'));
    expect(updated.isSubmitted, isTrue);
  });

  testWidgets('TEST 3: Feedback screen displays traveller and route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
          route: 'Coimbatore → Chennai',
        ),
      ),
    );

    expect(find.text('Rate Your Delivery'), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('Coimbatore → Chennai'), findsOneWidget);
  });

  testWidgets('TEST 4: Submit button is disabled before rating selection', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
        ),
      ),
    );

    final submitBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit Feedback'));
    expect(submitBtn.onPressed, isNull);
  });

  testWidgets('TEST 5: Selecting 1 star updates rating to 1/5', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
        ),
      ),
    );

    // Tap first star
    await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Rating: 1/5'), findsOneWidget);

    final submitBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit Feedback'));
    expect(submitBtn.onPressed, isNotNull);
  });

  testWidgets('TEST 6: Selecting 5 stars updates rating to 5/5', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
        ),
      ),
    );

    // Tap fifth star
    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(4));
    await tester.pumpAndSettle();

    expect(find.text('Rating: 5/5'), findsOneWidget);
  });

  testWidgets('TEST 7: Feedback text can be entered', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Very smooth delivery experience.');
    await tester.pumpAndSettle();

    expect(find.text('Very smooth delivery experience.'), findsOneWidget);
  });

  testWidgets('TEST 8 & 9: Submission succeeds and confirmation screen displays submitted rating', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
          route: 'Coimbatore → Chennai',
        ),
      ),
    );

    // Tap 5 stars
    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(4));
    await tester.pumpAndSettle();

    // Enter feedback
    await tester.enterText(find.byType(TextFormField), 'Fast and safe handover!');
    await tester.pumpAndSettle();

    // Submit
    final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Feedback');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SenderFeedbackConfirmationScreen), findsOneWidget);
    expect(find.text('Thank You!'), findsOneWidget);
    expect(find.text('Your feedback has been submitted successfully.'), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('★ 5.0'), findsOneWidget);
  });

  testWidgets('TEST 10: Duplicate submission is prevented when isSubmitted == true', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final submittedRating = SenderDeliveryRating(
      id: 'RAT-DONE',
      requestId: 'REQ-DONE',
      bookingId: 'BKG-DONE',
      travellerName: 'Arun',
      route: 'Coimbatore → Chennai',
      rating: 5.0,
      feedback: 'Already submitted feedback.',
      submittedAt: DateTime.now(),
      isSubmitted: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          ratingData: submittedRating,
        ),
      ),
    );

    expect(find.text('Feedback Already Submitted'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Submit Feedback'), findsNothing);
  });

  testWidgets('TEST 11: Completed delivery provides "Rate Traveller" entry point', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final completion = SenderMockDeliveryCompletionData.getMockCompletions().first;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryCompletionScreen(completion: completion),
      ),
    );

    final rateBtn = find.text('Rate Traveller');
    expect(rateBtn, findsOneWidget);
    await tester.ensureVisible(rateBtn);
    await tester.tap(rateBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SenderDeliveryFeedbackScreen), findsOneWidget);
  });

  testWidgets('TEST 12: Existing completed booking functionality still renders correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final deliveredBooking = SenderMockBookingData.getMockBookings()
        .firstWhere((b) => b.status == SenderDeliveryStatus.delivered);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderBookingDetailScreen(booking: deliveredBooking),
      ),
    );

    expect(find.text('Rate Traveller'), findsOneWidget);
    expect(find.text('View Delivery Proof'), findsOneWidget);

    await tester.tap(find.text('Rate Traveller'));
    await tester.pumpAndSettle();

    expect(find.byType(SenderDeliveryFeedbackScreen), findsOneWidget);
  });
}
