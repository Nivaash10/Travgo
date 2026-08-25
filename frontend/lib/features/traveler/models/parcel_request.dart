import '../../tracking/models/tracking_model.dart';
import '../../../models/travgo_delivery_booking.dart';

class ParcelRequest {
  final String id;
  final String tripId;
  final String senderName;
  final String? senderPhone;
  final String parcelDescription;
  final double parcelWeight;
  final String source;
  final String destination;
  final double price;
  String status;
  final String? receiverName;
  final String? receiverPhone;
  final String? deliveryLocation;
  final String? deliveryCity;

  ParcelRequest({
    required this.id,
    required this.tripId,
    required this.senderName,
    this.senderPhone,
    required this.parcelDescription,
    required this.parcelWeight,
    required this.source,
    required this.destination,
    required this.price,
    this.status = 'PENDING',
    this.receiverName,
    this.receiverPhone,
    this.deliveryLocation,
    this.deliveryCity,
  });

  ParcelTrip toParcelTrip() {
    return ParcelTrip(
      parcelId: id.isNotEmpty ? id : 'TRV1024',
      tripId: tripId.isNotEmpty ? tripId : 'TRIP001',
      sourceName: source,
      sourceLocation: TravgoDeliveryBooking.getCityCoordinates(source),
      destinationName: destination,
      destinationLocation: TravgoDeliveryBooking.getCityCoordinates(destination),
      travellerName: 'Arun Kumar',
      status: status == 'DELIVERED'
          ? ParcelStatus.delivered
          : (status == 'PICKED_UP' || status == 'IN_TRANSIT')
              ? ParcelStatus.inTransit
              : ParcelStatus.pickedUp,
    );
  }
}
