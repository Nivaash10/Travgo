import '../models/traveler_trip.dart';
import '../../sender/models/sender_traveller_match.dart';
import '../../common/services/pricing_service.dart';

/// Central repository managing Traveller Trips and dynamic matching with Sender requests.
class TravelerTripRepository {
  static final TravelerTripRepository _instance = TravelerTripRepository._internal();
  factory TravelerTripRepository() => _instance;
  TravelerTripRepository._internal();

  final List<TravelerTrip> _trips = [];
  bool isVerified = true;
  String? profileImagePath;

  List<TravelerTrip> get trips => List.unmodifiable(_trips);

  TravelerTrip? get activeTrip {
    try {
      return _trips.firstWhere((trip) => trip.status == 'ACTIVE');
    } catch (_) {
      return null;
    }
  }

  int get tripCount => _trips.length;

  void addTrip(TravelerTrip trip) {
    _trips.insert(0, trip);
  }

  List<SenderTravellerMatch> findMatches(
    String source,
    String destination, {
    double? weight,
    DateTime? date,
  }) {
    final matches = <SenderTravellerMatch>[];
    final sLower = source.trim().toLowerCase();
    final dLower = destination.trim().toLowerCase();

    for (var trip in _trips) {
      if (trip.status != 'ACTIVE') continue;

      final tripSrc = trip.source.trim().toLowerCase();
      final tripDst = trip.destination.trim().toLowerCase();

      final routeMatches = (tripSrc.contains(sLower) || sLower.contains(tripSrc)) &&
          (tripDst.contains(dLower) || dLower.contains(tripDst));

      final weightMatches = weight == null || trip.availableWeight >= weight;

      final dateMatches = date == null ||
          (trip.travelDate.year == date.year &&
              trip.travelDate.month == date.month &&
              trip.travelDate.day == date.day);

      if (routeMatches && weightMatches && dateMatches) {
        final calcPrice = PricingService.calculateEstimatedPrice(
          source: trip.source,
          destination: trip.destination,
          weightKg: weight ?? 2.5,
        );

        matches.add(
          SenderTravellerMatch(
            travellerName: 'Verified Traveller',
            rating: 4.8,
            route: '${trip.source} → ${trip.destination}',
            travelDateTime: '${trip.travelDate.day}/${trip.travelDate.month}/${trip.travelDate.year} • ${trip.travelTime}',
            availableCapacityKg: trip.availableWeight,
            priceRupees: trip.price > 0 ? trip.price : calcPrice,
            isVerified: isVerified,
          ),
        );
      }
    }
    return matches;
  }
}
