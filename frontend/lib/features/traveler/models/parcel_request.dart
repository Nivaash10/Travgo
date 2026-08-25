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
}
