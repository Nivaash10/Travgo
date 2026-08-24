import '../models/sender_payment.dart';

/// Isolated frontend-only mock dataset for Sender payments.
class SenderMockPaymentData {
  static List<SenderPayment> getMockPayments() {
    final now = DateTime.now();

    return [
      // 1. Pending Payment
      SenderPayment(
        paymentId: 'PAY-101',
        bookingId: 'BKG-101',
        requestId: 'REQ-101',
        amountRupees: 115.0,
        paymentMethod: 'UPI',
        status: SenderPaymentStatus.pending,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),

      // 2. Paid / Successful Payment
      SenderPayment(
        paymentId: 'PAY-102',
        bookingId: 'BKG-102',
        requestId: 'REQ-102',
        amountRupees: 165.0,
        paymentMethod: 'Credit Card',
        status: SenderPaymentStatus.paid,
        createdAt: now.subtract(const Duration(days: 1)),
        paidAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),

      // 3. Failed Payment
      SenderPayment(
        paymentId: 'PAY-103',
        bookingId: 'BKG-103',
        requestId: 'REQ-103',
        amountRupees: 215.0,
        paymentMethod: 'Net Banking',
        status: SenderPaymentStatus.failed,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),

      // 4. Refunded Payment
      SenderPayment(
        paymentId: 'PAY-104',
        bookingId: 'BKG-106',
        requestId: 'REQ-106',
        amountRupees: 105.0,
        paymentMethod: 'UPI',
        status: SenderPaymentStatus.refunded,
        createdAt: now.subtract(const Duration(days: 3)),
        paidAt: now.subtract(const Duration(days: 3, hours: 1)),
      ),
    ];
  }
}
