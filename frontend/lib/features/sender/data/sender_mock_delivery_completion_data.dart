import '../models/sender_delivery_completion.dart';
import '../models/sender_delivery_status.dart';

/// Isolated frontend-only mock dataset for Sender delivery completions.
class SenderMockDeliveryCompletionData {
  static List<SenderDeliveryCompletion> getMockCompletions() {
    final now = DateTime.now();

    return [
      // 1. Successfully delivered with proof available
      SenderDeliveryCompletion(
        bookingId: 'BKG-105',
        requestId: 'REQ-105',
        deliveryStatus: SenderDeliveryStatus.delivered,
        deliveredAt: now.subtract(const Duration(hours: 4)),
        receiverName: 'Suresh Kumar',
        destination: 'Coimbatore RS Puram',
        travellerName: 'Ravi',
        travellerVerified: true,
        travellerRating: 4.9,
        parcelDescription: 'Important Legal Contracts',
        parcelCategory: 'Documents',
        parcelWeightKg: 1.5,
        proofOfDeliveryAvailable: true,
        proofType: 'OTP Verification & Digital Signature',
        proofReference: 'POD-BKG-105-892',
        deliveryMessage: 'Parcel handed over safely to recipient after OTP verification.',
      ),

      // 2. Delivered with proof pending
      SenderDeliveryCompletion(
        bookingId: 'BKG-104',
        requestId: 'REQ-104',
        deliveryStatus: SenderDeliveryStatus.delivered,
        deliveredAt: now.subtract(const Duration(minutes: 30)),
        receiverName: 'Priya Sharma',
        destination: 'Chennai Koyambedu',
        travellerName: 'Karthik',
        travellerVerified: true,
        travellerRating: 4.8,
        parcelDescription: 'Electronic Accessories',
        parcelCategory: 'Electronics',
        parcelWeightKg: 2.5,
        proofOfDeliveryAvailable: false,
        proofType: 'Digital Receipt',
        proofReference: null,
        deliveryMessage: 'Handover complete. Digital receipt generation in progress.',
      ),

      // 3. Delivered without proof currently available
      SenderDeliveryCompletion(
        bookingId: 'BKG-102',
        requestId: 'REQ-102',
        deliveryStatus: SenderDeliveryStatus.delivered,
        deliveredAt: now.subtract(const Duration(days: 2)),
        receiverName: 'Ramesh V',
        destination: 'Bangalore Indiranagar',
        travellerName: 'Bala',
        travellerVerified: true,
        travellerRating: 4.7,
        parcelDescription: 'Clothes & Gift Items',
        parcelCategory: 'Personal Goods',
        parcelWeightKg: 3.0,
        proofOfDeliveryAvailable: false,
        proofType: null,
        proofReference: null,
        deliveryMessage: 'Parcel delivered successfully.',
      ),
    ];
  }

  static SenderDeliveryCompletion getCompletionForBooking(String bookingId) {
    final completions = getMockCompletions();
    final match = completions.where((c) => c.bookingId == bookingId || c.requestId == bookingId).firstOrNull;

    if (match != null) return match;

    final now = DateTime.now();
    return SenderDeliveryCompletion(
      bookingId: bookingId,
      requestId: 'REQ-$bookingId',
      deliveryStatus: SenderDeliveryStatus.delivered,
      deliveredAt: now.subtract(const Duration(hours: 2)),
      receiverName: 'Recipient Name',
      destination: 'Destination Hub',
      travellerName: 'Arun',
      travellerVerified: true,
      travellerRating: 4.8,
      parcelDescription: 'Sample Parcel',
      parcelCategory: 'General',
      parcelWeightKg: 2.0,
      proofOfDeliveryAvailable: true,
      proofType: 'OTP Verification & Digital Signature',
      proofReference: 'POD-$bookingId-771',
      deliveryMessage: 'Parcel handed over successfully to recipient.',
    );
  }
}
