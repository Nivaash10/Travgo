/// Presentation model for Sender matching travellers results.
///
/// Note: This is a frontend presentation structure only.
/// Official API contract and data mappings will be provided by Person 1 later.
class SenderTravellerMatch {
  final String travellerName;
  final bool isVerified;
  final String route;
  final String travelDateTime;
  final double availableCapacityKg;
  final double priceRupees;
  final double? rating;

  const SenderTravellerMatch({
    required this.travellerName,
    this.isVerified = false,
    required this.route,
    required this.travelDateTime,
    required this.availableCapacityKg,
    required this.priceRupees,
    this.rating,
  });
}
