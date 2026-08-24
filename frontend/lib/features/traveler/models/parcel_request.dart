class ParcelRequest {
  final String id;
  final String tripId;
  final String senderName;
  final String parcelDescription;
  final double parcelWeight;
  final String source;
  final String destination;
  final double price;
  String status;

  ParcelRequest({
    required this.id,
    required this.tripId,
    required this.senderName,
    required this.parcelDescription,
    required this.parcelWeight,
    required this.source,
    required this.destination,
    required this.price,
    this.status = 'PENDING',
  });
}
