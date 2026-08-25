import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_notification_data.dart';
import 'package:frontend/features/sender/data/sender_mock_tracking_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_completion.dart';
import 'package:frontend/features/sender/models/sender_delivery_rating.dart';
import 'package:frontend/features/sender/models/sender_tracking.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_feedback_screen.dart';
import 'package:frontend/features/sender/screens/sender_payment_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';

void main() {
  group('Phase 16 Mock Data Isolation & Immutability Tests', () {
    test('getMockBookings returns new instances on each invocation', () {
      final list1 = SenderMockBookingData.getMockBookings();
      final list2 = SenderMockBookingData.getMockBookings();

      expect(identical(list1, list2), isFalse);
      expect(list1.length, equals(list2.length));
    });

    test('getMockNotifications returns new instances on each invocation', () {
      final list1 = SenderMockNotificationData.getMockNotifications();
      final list2 = SenderMockNotificationData.getMockNotifications();

      expect(identical(list1, list2), isFalse);
      expect(list1.length, equals(list2.length));
    });

    test('getMockTrackings returns new instances on each invocation', () {
      final list1 = SenderMockTrackingData.getMockTrackings();
      final list2 = SenderMockTrackingData.getMockTrackings();

      expect(identical(list1, list2), isFalse);
      expect(list1.length, equals(list2.length));
    });
  });

  group('Phase 16 Null Safety & Fallback Behavior Tests', () {
    test('SenderTracking model handles optional fields cleanly', () {
      final tracking = SenderTracking(
        bookingId: 'BKG-NULL',
        requestId: 'REQ-NULL',
        currentStatus: SenderTrackingStatus.accepted,
        statusMessage: 'Status message',
        source: 'Coimbatore',
        destination: 'Chennai',
        travellerName: 'Arun',
        travelDateTime: '25 Aug 2026 • 8:30 AM',
        lastUpdated: DateTime.now(),
      );

      expect(tracking.currentLocation, isNull);
      expect(tracking.events, isEmpty);
    });

    test('SenderDeliveryCompletion model handles optional fields cleanly', () {
      final completion = SenderDeliveryCompletion(
        bookingId: 'BKG-NULL',
        requestId: 'REQ-NULL',
        deliveredAt: DateTime.now(),
        receiverName: 'Ravi',
        destination: 'Chennai',
        travellerName: 'Arun',
        parcelDescription: 'Box',
        parcelWeightKg: 1.5,
        deliveryMessage: 'Parcel handed over to receiver.',
      );

      expect(completion.proofOfDeliveryAvailable, isTrue);
      expect(completion.proofType, isNull);
      expect(completion.proofReference, isNull);
    });

    test('SenderDeliveryRating model handles missing optional feedback cleanly', () {
      final rating = SenderDeliveryRating(
        id: 'RAT-NULL',
        requestId: 'REQ-NULL',
        bookingId: 'BKG-NULL',
        travellerName: 'Arun',
        submittedAt: DateTime.now(),
      );

      expect(rating.rating, equals(0.0));
      expect(rating.feedback, isNull);
      expect(rating.isSubmitted, isFalse);
      expect(rating.isValidRating, isFalse);
    });
  });

  group('Phase 16 Screen Robustness & Edge Case Rendering Tests', () {
    testWidgets('SenderTrackingScreen renders safely with minimal optional fields', (tester) async {
      final minimalTracking = SenderTracking(
        bookingId: 'BKG-MIN',
        requestId: 'REQ-MIN',
        currentStatus: SenderTrackingStatus.pickedUp,
        statusMessage: 'Picked up parcel',
        source: 'Coimbatore',
        destination: 'Madurai',
        travellerName: 'Bala',
        travelDateTime: 'Today • 10:00 AM',
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SenderTrackingScreen(tracking: minimalTracking),
        ),
      );

      expect(find.text('Live Tracking'), findsOneWidget);
    });

    testWidgets('SenderDeliveryCompletionScreen renders safely with proof disabled', (tester) async {
      final noProofCompletion = SenderDeliveryCompletion(
        bookingId: 'BKG-NOPROOF',
        requestId: 'REQ-NOPROOF',
        deliveredAt: DateTime.now(),
        receiverName: 'Suresh',
        destination: 'Trichy',
        travellerName: 'Karthik',
        parcelDescription: 'Small pouch',
        parcelWeightKg: 0.5,
        proofOfDeliveryAvailable: false,
        deliveryMessage: 'Parcel safely delivered to Suresh.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SenderDeliveryCompletionScreen(completion: noProofCompletion),
        ),
      );

      expect(find.text('Delivery Status'), findsOneWidget);
      expect(find.text('PROOF OF DELIVERY'), findsOneWidget);
    });

    testWidgets('SenderDeliveryFeedbackScreen renders cleanly and validates feedback submission', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final unsubmittedRating = SenderDeliveryRating(
        id: 'RAT-TEST',
        requestId: 'REQ-TEST',
        bookingId: 'BKG-TEST',
        travellerName: 'Arun',
        route: 'Coimbatore → Chennai',
        rating: 4.0,
        submittedAt: DateTime.now(),
        isSubmitted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SenderDeliveryFeedbackScreen(
            ratingData: unsubmittedRating,
          ),
        ),
      );

      expect(find.text('Rate & Review'), findsOneWidget);

      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Review (4 Stars)');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.text('Thank You!'), findsOneWidget);
    });


    testWidgets('SenderBookingDetailScreen renders with all delivery status states', (tester) async {
      final booking = SenderMockBookingData.getMockBookings().first;

      await tester.pumpWidget(
        MaterialApp(
          home: SenderBookingDetailScreen(booking: booking),
        ),
      );

      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('BKG-101'), findsOneWidget);
    });

    testWidgets('SenderPaymentScreen renders pay button and handles payment submit', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final booking = SenderMockBookingData.getMockBookings().first;
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SenderPaymentScreen(
            booking: booking,
            delayDuration: Duration.zero,
            onPaymentCompleted: (_) => completed = true,
          ),
        ),
      );

      final payButtonFinder = find.text('Pay ₹115');
      await tester.ensureVisible(payButtonFinder);
      await tester.pumpAndSettle();

      expect(payButtonFinder, findsOneWidget);
      await tester.tap(payButtonFinder);
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });
}
