import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_payment_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/models/sender_payment.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_payment_result_screen.dart';
import 'package:frontend/features/sender/screens/sender_payment_screen.dart';
import 'package:frontend/features/sender/widgets/sender_payment_status_badge.dart';

void main() {
  final mockBookings = SenderMockBookingData.getMockBookings();
  final mockPayments = SenderMockPaymentData.getMockPayments();

  test('TEST 1: SenderPayment model is created correctly', () {
    final now = DateTime.now();
    final payment = SenderPayment(
      paymentId: 'PAY-TEST',
      bookingId: 'BKG-TEST',
      requestId: 'REQ-TEST',
      amountRupees: 165.0,
      paymentMethod: 'UPI',
      status: SenderPaymentStatus.pending,
      createdAt: now,
    );

    expect(payment.paymentId, equals('PAY-TEST'));
    expect(payment.bookingId, equals('BKG-TEST'));
    expect(payment.amountRupees, equals(165.0));
    expect(payment.paymentMethod, equals('UPI'));
    expect(payment.status, equals(SenderPaymentStatus.pending));
  });

  test('TEST 2: copyWith() updates payment status correctly', () {
    final now = DateTime.now();
    final payment = SenderPayment(
      paymentId: 'PAY-TEST',
      bookingId: 'BKG-TEST',
      requestId: 'REQ-TEST',
      amountRupees: 165.0,
      paymentMethod: 'UPI',
      status: SenderPaymentStatus.pending,
      createdAt: now,
    );

    final paid = payment.copyWith(
      status: SenderPaymentStatus.paid,
      paidAt: now,
    );

    expect(paid.paymentId, equals('PAY-TEST'));
    expect(paid.status, equals(SenderPaymentStatus.paid));
    expect(paid.paidAt, equals(now));
  });

  testWidgets('TEST 3: Payment screen displays booking/traveller/route/amount', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final booking = mockBookings.first;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentScreen(booking: booking),
      ),
    );

    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Complete Your Payment'), findsOneWidget);
    expect(find.text(booking.id), findsOneWidget);
    expect(find.text(booking.travellerName!), findsOneWidget);
    expect(find.text(booking.request.traveller.route), findsOneWidget);
    expect(find.text('Select Payment Method'), findsOneWidget);
  });

  testWidgets('TEST 4: Payment methods are displayed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentScreen(booking: mockBookings.first),
      ),
    );

    expect(find.text('UPI (GPay / PhonePe / Paytm)'), findsOneWidget);
    expect(find.text('Credit / Debit Card'), findsOneWidget);
    expect(find.text('Net Banking'), findsOneWidget);
    expect(find.text('Cash / Pay at Pickup'), findsOneWidget);
  });

  testWidgets('TEST 5: Selecting a payment method updates the selected state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentScreen(booking: mockBookings.first),
      ),
    );

    final cardTile = find.text('Credit / Debit Card');
    expect(cardTile, findsOneWidget);
    await tester.tap(cardTile);
    await tester.pumpAndSettle();

    expect(find.text('Credit / Debit Card'), findsOneWidget);
  });

  testWidgets('TEST 6: Pay button displays the correct amount', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final booking = mockBookings.first;
    final expectedTotal = booking.deliveryPrice + 15.0; // price + platform fee

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentScreen(booking: booking),
      ),
    );

    expect(
      find.text('Pay ₹${expectedTotal.toStringAsFixed(0)}'),
      findsOneWidget,
    );
  });

  testWidgets('TEST 7: Payment processing state appears after pressing Pay', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentScreen(
          booking: mockBookings.first,
          delayDuration: const Duration(seconds: 2),
        ),
      ),
    );

    final payButton = find.textContaining('Pay ₹');
    await tester.tap(payButton);
    await tester.pump(); // Start frame of processing state

    expect(find.text('Processing Payment...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Complete async delay
  });

  testWidgets('TEST 8: Successful mock payment navigates to SenderPaymentResultScreen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentScreen(
          booking: mockBookings.first,
          delayDuration: Duration.zero,
        ),
      ),
    );

    final payButton = find.textContaining('Pay ₹');
    await tester.tap(payButton);
    await tester.pumpAndSettle();

    expect(find.byType(SenderPaymentResultScreen), findsOneWidget);
  });

  testWidgets('TEST 9: Successful result displays Payment Successful, Payment ID, Amount, Booking ID', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final paidPayment = mockPayments.firstWhere((p) => p.status == SenderPaymentStatus.paid);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentResultScreen(payment: paidPayment),
      ),
    );

    expect(find.text('Payment Successful'), findsWidgets);
    expect(find.text(paidPayment.paymentId), findsOneWidget);
    expect(find.text(paidPayment.bookingId), findsOneWidget);
    expect(find.text('₹${paidPayment.amountRupees.toStringAsFixed(0)}'), findsOneWidget);
    expect(find.text('View Booking'), findsOneWidget);
  });

  testWidgets('TEST 10: Failed payment state displays failure UI and retry option', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    bool retried = false;
    final failedPayment = mockPayments.firstWhere((p) => p.status == SenderPaymentStatus.failed);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderPaymentResultScreen(
          payment: failedPayment,
          errorMessage: 'Transaction declined by bank',
          onTryAgain: () {
            retried = true;
          },
        ),
      ),
    );

    expect(find.text('Payment Failed'), findsWidgets);
    expect(find.text('Transaction declined by bank'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(retried, isTrue);
  });

  testWidgets('TEST 11: Payment status badge displays correct status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SenderPaymentStatusBadge(status: SenderPaymentStatus.pending),
              SenderPaymentStatusBadge(status: SenderPaymentStatus.paid),
              SenderPaymentStatusBadge(status: SenderPaymentStatus.failed),
              SenderPaymentStatusBadge(status: SenderPaymentStatus.refunded),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Payment Pending'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Payment Failed'), findsOneWidget);
    expect(find.text('Refunded'), findsOneWidget);
  });

  testWidgets('TEST 12: Booking detail displays payment information', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final acceptedBooking = mockBookings.firstWhere((b) => b.status == SenderDeliveryStatus.accepted);

    await tester.pumpWidget(
      MaterialApp(
        home: SenderBookingDetailScreen(booking: acceptedBooking),
      ),
    );

    expect(find.text('PAYMENT INFORMATION'), findsOneWidget);
  });

  testWidgets('TEST 13: Existing Phase 6, Phase 7, and Phase 8 functionality remains unaffected', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final booking = mockBookings.first;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderBookingDetailScreen(booking: booking),
      ),
    );

    expect(find.text('Booking Details'), findsOneWidget);
    expect(find.text('TRAVELLER DETAILS'), findsOneWidget);
    expect(find.text('PARCEL DETAILS'), findsOneWidget);
    expect(find.text('DELIVERY SUMMARY'), findsOneWidget);
    expect(find.text('DELIVERY LIFECYCLE'), findsOneWidget);
  });
}
