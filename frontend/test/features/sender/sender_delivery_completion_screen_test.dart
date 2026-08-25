import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_delivery_completion_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_completion.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';

import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_proof_viewer_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';

void main() {
  final mockCompletions = SenderMockDeliveryCompletionData.getMockCompletions();

  test('TEST 1: Delivery completion model can be created', () {
    final now = DateTime.now();
    final completion = SenderDeliveryCompletion(
      bookingId: 'BKG-TEST',
      requestId: 'REQ-TEST',
      deliveredAt: now,
      receiverName: 'Ramesh',
      destination: 'Chennai',
      travellerName: 'Arun',
      parcelDescription: 'Test Parcel',
      parcelWeightKg: 2.0,
      deliveryMessage: 'Delivered safely.',
    );

    expect(completion.bookingId, equals('BKG-TEST'));
    expect(completion.receiverName, equals('Ramesh'));
    expect(completion.destination, equals('Chennai'));
    expect(completion.travellerName, equals('Arun'));
    expect(completion.parcelWeightKg, equals(2.0));
  });

  test('TEST 2: copyWith() works correctly', () {
    final now = DateTime.now();
    final completion = SenderDeliveryCompletion(
      bookingId: 'BKG-TEST',
      requestId: 'REQ-TEST',
      deliveredAt: now,
      destination: 'Chennai',
      travellerName: 'Arun',
      parcelDescription: 'Test Parcel',
      parcelWeightKg: 2.0,
      deliveryMessage: 'Delivered safely.',
      proofOfDeliveryAvailable: false,
    );

    final updated = completion.copyWith(
      proofOfDeliveryAvailable: true,
      proofType: 'OTP Verification',
    );

    expect(updated.bookingId, equals('BKG-TEST'));
    expect(updated.proofOfDeliveryAvailable, isTrue);
    expect(updated.proofType, equals('OTP Verification'));
  });

  testWidgets(
    'TEST 3: Completion screen displays "Parcel Delivered Successfully"',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final completion = mockCompletions.first;

      await tester.pumpWidget(
        MaterialApp(
          home: SenderDeliveryCompletionScreen(completion: completion),
        ),
      );

      expect(find.text('Delivery Status'), findsOneWidget);
      expect(find.text('Delivery Completed!'), findsOneWidget);
    },
  );

  testWidgets(
    'TEST 4: Booking ID, route, traveller and delivery time are displayed',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final completion = mockCompletions.first;

      await tester.pumpWidget(
        MaterialApp(
          home: SenderDeliveryCompletionScreen(completion: completion),
        ),
      );

      expect(find.text('Booking ID: ${completion.bookingId}'), findsOneWidget);
      expect(find.text(completion.travellerName), findsOneWidget);
    },
  );

  testWidgets('TEST 5: Shipment summary is displayed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final completion = mockCompletions.first;

    await tester.pumpWidget(
      MaterialApp(home: SenderDeliveryCompletionScreen(completion: completion)),
    );

    expect(find.text('SHIPMENT SUMMARY'), findsOneWidget);
    expect(find.text(completion.travellerName), findsOneWidget);
  });

  testWidgets('TEST 6: Proof Available state is displayed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final availableCompletion = mockCompletions.firstWhere(
      (c) => c.proofOfDeliveryAvailable,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryCompletionScreen(completion: availableCompletion),
      ),
    );

    expect(find.text('PROOF OF DELIVERY'), findsOneWidget);
    expect(find.text('View Digital Proof'), findsOneWidget);
  });

  testWidgets(
    'TEST 7: Proof Pending / unavailable state is displayed correctly',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final pendingCompletion = mockCompletions.firstWhere(
        (c) => !c.proofOfDeliveryAvailable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SenderDeliveryCompletionScreen(completion: pendingCompletion),
        ),
      );

      expect(find.text('PROOF OF DELIVERY'), findsOneWidget);
    },
  );

  testWidgets('TEST 8: View Digital Proof opens SenderProofViewerScreen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final availableCompletion = mockCompletions.firstWhere(
      (c) => c.proofOfDeliveryAvailable,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryCompletionScreen(completion: availableCompletion),
      ),
    );

    final viewProofBtn = find.text('View Digital Proof');
    expect(viewProofBtn, findsOneWidget);
    await tester.ensureVisible(viewProofBtn);
    await tester.tap(viewProofBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SenderProofViewerScreen), findsOneWidget);
    expect(find.text('VERIFIED HANDOVER'), findsOneWidget);
  });

  testWidgets('TEST 9: All Bookings action works', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryCompletionScreen(completion: mockCompletions.first),
      ),
    );

    final backBtn = find.text('All Bookings');
    expect(backBtn, findsOneWidget);
    await tester.ensureVisible(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.byType(MyBookingsScreen), findsOneWidget);
  });

  testWidgets(
    'TEST 10: Delivered booking from SenderBookingDetailScreen opens completion screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final deliveredBooking = SenderMockBookingData.getMockBookings()
          .firstWhere((b) => b.status == SenderDeliveryStatus.delivered);

      await tester.pumpWidget(
        MaterialApp(home: SenderBookingDetailScreen(booking: deliveredBooking)),
      );

      final viewProofBtn = find.text('View Delivery Proof');
      expect(viewProofBtn, findsOneWidget);
      await tester.ensureVisible(viewProofBtn);
      await tester.tap(viewProofBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SenderDeliveryCompletionScreen), findsOneWidget);
    },
  );

  testWidgets(
    'TEST 11: Delivered state in SenderTrackingScreen displays completion action',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final deliveredBooking = SenderMockBookingData.getMockBookings()
          .firstWhere((b) => b.status == SenderDeliveryStatus.delivered);

      await tester.pumpWidget(
        MaterialApp(home: SenderBookingDetailScreen(booking: deliveredBooking)),
      );

      final trackBtn = find.text('Track Delivery');
      expect(trackBtn, findsOneWidget);
      await tester.ensureVisible(trackBtn);
      await tester.tap(trackBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SenderTrackingScreen), findsOneWidget);

      final viewConfirmationBtn = find.text('View Delivery Confirmation');
      expect(viewConfirmationBtn, findsOneWidget);
      await tester.ensureVisible(viewConfirmationBtn);
      await tester.tap(viewConfirmationBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SenderDeliveryCompletionScreen), findsOneWidget);
    },
  );

  testWidgets('TEST 12: Loading state displays CircularProgressIndicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SenderDeliveryCompletionScreen(isLoading: true)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading completion details...'), findsOneWidget);
  });

  testWidgets('TEST 13: Error state displays error message and Try Again', (
    tester,
  ) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryCompletionScreen(
          errorMessage: 'Failed to load details',
          onRetry: () {
            retried = true;
          },
        ),
      ),
    );

    expect(
      find.text('Unable to load delivery completion details'),
      findsOneWidget,
    );
    expect(find.text('Failed to load details'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(retried, isTrue);
  });

  testWidgets('TEST 14: Existing Track Delivery navigation still works', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final booking = SenderMockBookingData.getMockBookings().first.copyWith(status: SenderDeliveryStatus.inTransit);

    await tester.pumpWidget(
      MaterialApp(home: SenderBookingDetailScreen(booking: booking)),
    );

    final trackBtn = find.text('Track Delivery');
    expect(trackBtn, findsOneWidget);
    await tester.ensureVisible(trackBtn);
    await tester.tap(trackBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SenderTrackingScreen), findsOneWidget);
  });

  testWidgets('TEST 15: Existing cancellation functionality is not broken', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final booking = SenderMockBookingData.getMockBookings().first;

    await tester.pumpWidget(
      MaterialApp(home: SenderBookingDetailScreen(booking: booking)),
    );

    final cancelBtn = find.text('Cancel Request');
    expect(cancelBtn, findsOneWidget);
    await tester.ensureVisible(cancelBtn);
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    expect(find.text('Cancel Delivery Request?'), findsOneWidget);
  });
}
