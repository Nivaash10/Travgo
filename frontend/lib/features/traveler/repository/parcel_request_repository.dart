import '../models/parcel_request.dart';

class ParcelRequestRepository {
  static final ParcelRequestRepository _instance = ParcelRequestRepository._internal();
  factory ParcelRequestRepository() => _instance;

  final List<ParcelRequest> _requests = [
    ParcelRequest(
      id: 'req_1',
      tripId: 'trip_1',
      senderName: 'Ramesh Kumar',
      parcelDescription: 'Electronics & Laptop Charger',
      parcelWeight: 2.0,
      source: 'Coimbatore',
      destination: 'Chennai',
      price: 250.0,
      status: 'PENDING',
    ),
    ParcelRequest(
      id: 'req_2',
      tripId: 'trip_1',
      senderName: 'Ananya Sharma',
      parcelDescription: 'Important Documents & Books',
      parcelWeight: 1.5,
      source: 'Coimbatore',
      destination: 'Chennai',
      price: 180.0,
      status: 'PENDING',
    ),
  ];

  ParcelRequestRepository._internal();

  List<ParcelRequest> get requests => List.unmodifiable(_requests);

  List<ParcelRequest> getRequestsForTrip(String? tripId) {
    if (tripId == null || tripId.isEmpty) {
      return List.unmodifiable(_requests);
    }
    final filtered = _requests.where((req) => req.tripId == tripId).toList();
    if (filtered.isEmpty) {
      return List.unmodifiable(_requests);
    }
    return List.unmodifiable(filtered);
  }

  int getPendingRequestCount(String? tripId) {
    return getRequestsForTrip(tripId).where((req) => req.status == 'PENDING').length;
  }

  int getTotalRequestCount() {
    return _requests.length;
  }

  void addRequest(ParcelRequest request) {
    _requests.insert(0, request);
  }

  void updateRequestStatus(String requestId, String newStatus) {
    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      _requests[index].status = newStatus;
    }
  }
}
