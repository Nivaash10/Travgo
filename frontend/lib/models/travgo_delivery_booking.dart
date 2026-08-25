import 'package:latlong2/latlong.dart';
import '../features/tracking/models/tracking_model.dart';
import '../features/traveler/models/parcel_request.dart';
import '../features/sender/models/sender_delivery_status.dart';
import '../features/sender/models/sender_delivery_request.dart';
import '../features/sender/models/sender_search_query.dart';
import '../features/sender/models/sender_traveller_match.dart';

/// Single Source of Truth for TRAVGO Delivery & Trip lifecycle state.
class TravgoDeliveryBooking {
  final String parcelId;
  final String tripId;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String senderPhone;
  final String travellerId;
  final String travellerName;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final String? receiverLandmark;
  final String? receiverPincode;
  final String parcelCategory;
  final int parcelQuantity;
  final String? specialInstructions;
  final DateTime? deliveryDate;
  final String sourceName;
  final double sourceLatitude;
  final double sourceLongitude;
  final String destinationName;
  final double destinationLatitude;
  final double destinationLongitude;
  final String parcelDescription;
  final double parcelWeight;
  final double price;
  final String status; // REQUESTED, ACCEPTED, PAYMENT_HELD, PICKUP_PENDING, PICKED_UP, IN_TRANSIT, ARRIVING, DELIVERY_OTP_PENDING, DELIVERED, PAYMENT_RELEASED, RATED, COMPLETED
  final String pickupOtp;
  final String deliveryOtp;
  final bool pickupOtpVerified;
  final bool deliveryOtpVerified;
  final bool trackingActive;
  final DateTime? pickupVerifiedAt;
  final DateTime? deliveryVerifiedAt;
  final DateTime? locationUpdatedAt;
  final DateTime? deliveredAt;
  final String paymentStatus;
  final String escrowStatus;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravgoDeliveryBooking({
    required this.parcelId,
    required this.tripId,
    required this.bookingId,
    this.senderId = 'SND-101',
    this.senderName = 'Ramesh Kumar',
    this.senderPhone = '+91 98765 43210',
    this.travellerId = 'TRV-501',
    this.travellerName = 'Arun Kumar',
    this.receiverName = 'Priya Sharma',
    this.receiverPhone = '+91 98765 01234',
    this.receiverAddress = 'Anna Nagar, Chennai',
    this.receiverLandmark,
    this.receiverPincode,
    this.parcelCategory = 'Books',
    this.parcelQuantity = 1,
    this.specialInstructions,
    this.deliveryDate,
    required this.sourceName,
    double? sourceLatitude,
    double? sourceLongitude,
    required this.destinationName,
    double? destinationLatitude,
    double? destinationLongitude,
    required this.parcelDescription,
    required this.parcelWeight,
    required this.price,
    this.status = 'PAYMENT_HELD',
    this.pickupOtp = '4827',
    this.deliveryOtp = '7194',
    this.pickupOtpVerified = false,
    this.deliveryOtpVerified = false,
    this.trackingActive = false,
    this.pickupVerifiedAt,
    this.deliveryVerifiedAt,
    this.locationUpdatedAt,
    this.deliveredAt,
    this.paymentStatus = 'PAYMENT_ESCROWED',
    this.escrowStatus = 'HELD',
    this.currentLatitude,
    this.currentLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : sourceLatitude = sourceLatitude ?? getCityCoordinates(sourceName).latitude,
        sourceLongitude = sourceLongitude ?? getCityCoordinates(sourceName).longitude,
        destinationLatitude = destinationLatitude ?? getCityCoordinates(destinationName).latitude,
        destinationLongitude = destinationLongitude ?? getCityCoordinates(destinationName).longitude,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static LatLng getCityCoordinates(String cityName) {
    final name = cityName.trim().toLowerCase();
    if (name.contains('chennai')) {
      return const LatLng(13.0827, 80.2707);
    } else if (name.contains('madurai')) {
      return const LatLng(9.9252, 78.1198);
    } else if (name.contains('salem')) {
      return const LatLng(11.6643, 78.1460);
    } else if (name.contains('trichy') || name.contains('tiruchirappalli')) {
      return const LatLng(10.7905, 78.7047);
    } else if (name.contains('tirunelveli')) {
      return const LatLng(8.7139, 77.7567);
    } else if (name.contains('erode')) {
      return const LatLng(11.3410, 77.7172);
    } else if (name.contains('vellore')) {
      return const LatLng(12.9165, 79.1325);
    } else if (name.contains('hosur')) {
      return const LatLng(12.7409, 77.8253);
    } else if (name.contains('bangalore') || name.contains('bengaluru')) {
      return const LatLng(12.9716, 77.5946);
    } else if (name.contains('thanjavur')) {
      return const LatLng(10.7870, 79.1378);
    } else if (name.contains('kanchipuram')) {
      return const LatLng(12.8342, 79.7036);
    } else if (name.contains('tiruppur') || name.contains('tirupur')) {
      return const LatLng(11.1085, 77.3411);
    } else if (name.contains('coimbatore')) {
      return const LatLng(11.0168, 76.9558);
    }
    // Default fallback coordinate
    return const LatLng(11.0168, 76.9558);
  }

  TravgoDeliveryBooking copyWith({
    String? parcelId,
    String? tripId,
    String? bookingId,
    String? senderId,
    String? senderName,
    String? senderPhone,
    String? travellerId,
    String? travellerName,
    String? sourceName,
    double? sourceLatitude,
    double? sourceLongitude,
    String? destinationName,
    double? destinationLatitude,
    double? destinationLongitude,
    String? parcelDescription,
    double? parcelWeight,
    double? price,
    String? status,
    String? pickupOtp,
    String? deliveryOtp,
    bool? pickupOtpVerified,
    bool? deliveryOtpVerified,
    bool? trackingActive,
    DateTime? pickupVerifiedAt,
    DateTime? deliveryVerifiedAt,
    DateTime? locationUpdatedAt,
    DateTime? deliveredAt,
    String? paymentStatus,
    String? escrowStatus,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravgoDeliveryBooking(
      parcelId: parcelId ?? this.parcelId,
      tripId: tripId ?? this.tripId,
      bookingId: bookingId ?? this.bookingId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      travellerId: travellerId ?? this.travellerId,
      travellerName: travellerName ?? this.travellerName,
      sourceName: sourceName ?? this.sourceName,
      sourceLatitude: sourceLatitude ?? this.sourceLatitude,
      sourceLongitude: sourceLongitude ?? this.sourceLongitude,
      destinationName: destinationName ?? this.destinationName,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      parcelDescription: parcelDescription ?? this.parcelDescription,
      parcelWeight: parcelWeight ?? this.parcelWeight,
      price: price ?? this.price,
      status: status ?? this.status,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      pickupOtpVerified: pickupOtpVerified ?? this.pickupOtpVerified,
      deliveryOtpVerified: deliveryOtpVerified ?? this.deliveryOtpVerified,
      trackingActive: trackingActive ?? this.trackingActive,
      pickupVerifiedAt: pickupVerifiedAt ?? this.pickupVerifiedAt,
      deliveryVerifiedAt: deliveryVerifiedAt ?? this.deliveryVerifiedAt,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      escrowStatus: escrowStatus ?? this.escrowStatus,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this canonical booking to a Tracking [ParcelTrip]
  ParcelTrip toParcelTrip() {
    ParcelStatus pStatus = ParcelStatus.pickedUp;
    if (status == 'DELIVERED' || status == 'COMPLETED' || status == 'PAYMENT_RELEASED' || status == 'RATED') {
      pStatus = ParcelStatus.delivered;
    } else if (status == 'IN_TRANSIT' || status == 'PICKED_UP') {
      pStatus = ParcelStatus.inTransit;
    } else if (status == 'CANCELLED') {
      pStatus = ParcelStatus.cancelled;
    }

    return ParcelTrip(
      parcelId: parcelId,
      tripId: tripId,
      sourceName: sourceName,
      sourceLocation: LatLng(sourceLatitude, sourceLongitude),
      destinationName: destinationName,
      destinationLocation: LatLng(destinationLatitude, destinationLongitude),
      travellerName: travellerName,
      status: pStatus,
    );
  }

  /// Converts this canonical booking to a Traveler [ParcelRequest]
  ParcelRequest toParcelRequest() {
    return ParcelRequest(
      id: bookingId,
      tripId: tripId,
      senderName: senderName,
      senderPhone: senderPhone,
      parcelDescription: parcelDescription,
      parcelWeight: parcelWeight,
      source: sourceName,
      destination: destinationName,
      price: price,
      status: status,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      deliveryLocation: receiverAddress,
      deliveryCity: destinationName,
    );
  }

  /// Converts this canonical booking to a Sender [SenderDeliveryStatusItem]
  SenderDeliveryStatusItem toSenderDeliveryStatusItem() {
    SenderDeliveryStatus sStatus = SenderDeliveryStatus.accepted;
    if (status == 'PICKED_UP' || status == 'IN_TRANSIT') {
      sStatus = SenderDeliveryStatus.inTransit;
    } else if (status == 'DELIVERED' || status == 'COMPLETED' || status == 'PAYMENT_RELEASED' || status == 'RATED') {
      sStatus = SenderDeliveryStatus.delivered;
    } else if (status == 'PICKUP_PENDING') {
      sStatus = SenderDeliveryStatus.pickupPending;
    } else if (status == 'CANCELLED') {
      sStatus = SenderDeliveryStatus.cancelled;
    }

    final req = SenderDeliveryRequest(
      searchQuery: SenderSearchQuery(
        source: sourceName,
        destination: destinationName,
        date: createdAt,
        parcelWeightKg: parcelWeight,
      ),
      traveller: SenderTravellerMatch(
        travellerName: travellerName,
        rating: 4.8,
        route: '$sourceName → $destinationName',
        travelDateTime: 'Today • 10:00 AM',
        availableCapacityKg: 10.0,
        priceRupees: price,
        isVerified: true,
      ),
      parcelDescription: parcelDescription,
      parcelWeightKg: parcelWeight,
      parcelCategory: 'Standard',
    );

    return SenderDeliveryStatusItem(
      requestId: bookingId,
      request: req,
      status: sStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pickupLocation: sourceName,
      deliveryLocation: destinationName,
      parcelPickedUp: pickupOtpVerified || status == 'PICKED_UP' || status == 'IN_TRANSIT' || status == 'DELIVERED',
      delivered: deliveryOtpVerified || status == 'DELIVERED' || status == 'COMPLETED' || status == 'RATED',
    );
  }
}
