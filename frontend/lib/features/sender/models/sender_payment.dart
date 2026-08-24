/// Enum representing the status of a Sender payment.
enum SenderPaymentStatus {
  pending,
  processing,
  paid,
  failed,
  cancelled,
  refunded,
}

/// Presentation model representing a Sender payment transaction.
/// 
/// Note: This is a frontend presentation model.
/// Official API/backend mapping will be provided by Person 1.
class SenderPayment {
  final String paymentId;
  final String bookingId;
  final String requestId;
  final double amountRupees;
  final String paymentMethod;
  final SenderPaymentStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;

  const SenderPayment({
    required this.paymentId,
    required this.bookingId,
    required this.requestId,
    required this.amountRupees,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  SenderPayment copyWith({
    String? paymentId,
    String? bookingId,
    String? requestId,
    double? amountRupees,
    String? paymentMethod,
    SenderPaymentStatus? status,
    DateTime? createdAt,
    DateTime? paidAt,
  }) {
    return SenderPayment(
      paymentId: paymentId ?? this.paymentId,
      bookingId: bookingId ?? this.bookingId,
      requestId: requestId ?? this.requestId,
      amountRupees: amountRupees ?? this.amountRupees,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
