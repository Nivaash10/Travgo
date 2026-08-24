import '../models/traveler_trip.dart';

class TravelerTripRepository {
  static final TravelerTripRepository _instance = TravelerTripRepository._internal();
  factory TravelerTripRepository() => _instance;
  TravelerTripRepository._internal();

  final List<TravelerTrip> _trips = [];
  bool isVerified = false;
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
}
