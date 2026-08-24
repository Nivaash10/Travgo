class TravelerTrip {
  final String id;
  final String source;
  final String destination;
  final DateTime travelDate;
  final String travelTime;
  final double availableWeight;
  final double price;
  final bool isNegotiable;
  final String status;

  TravelerTrip({
    required this.id,
    required this.source,
    required this.destination,
    required this.travelDate,
    required this.travelTime,
    required this.availableWeight,
    required this.price,
    required this.isNegotiable,
    required this.status,
  });
}