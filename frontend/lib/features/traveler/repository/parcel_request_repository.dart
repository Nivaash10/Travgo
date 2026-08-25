import '../models/parcel_request.dart';
import '../../sender/data/sender_mock_booking_data.dart';
import '../../sender/models/sender_delivery_status.dart';

/// Single repository managing Traveller's incoming Parcel Requests,
/// dynamically synchronized with the central Sender delivery bookings.
class ParcelRequestRepository {
  static final ParcelRequestRepository _instance = ParcelRequestRepository._internal();
  factory ParcelRequestRepository() => _instance;

  final List<ParcelRequest> _dynamicRequests = [];

  ParcelRequestRepository._internal();

  List<ParcelRequest> get requests {
    final bookings = SenderMockBookingData.getMockBookings();
    final mappedBookings = bookings.map((b) {
      final req = b.request;
      final receiver = req.receiver;
      return ParcelRequest(
        id: b.id,
        tripId: 'TRIP-${b.id}',
        senderName: 'Ramesh Kumar',
        senderPhone: '+91 98765 43210',
        parcelDescription: req.parcelDescription,
        parcelWeight: req.parcelWeightKg,
        source: req.searchQuery.source,
        destination: req.searchQuery.destination,
        price: b.deliveryPrice,
        status: b.status.name.toUpperCase(),
        receiverName: receiver?.fullName,
        receiverPhone: receiver?.phoneNumber,
        deliveryLocation: receiver?.deliveryAddress ?? b.deliveryLocation,
        deliveryCity: req.searchQuery.destination,
      );
    }).toList();

    final all = [..._dynamicRequests];
    for (var mb in mappedBookings) {
      if (!all.any((r) => r.id == mb.id)) {
        all.add(mb);
      }
    }
    return List.unmodifiable(all);
  }

  List<ParcelRequest> getRequestsForTrip(String? tripId) {
    final currentRequests = requests;
    if (tripId == null || tripId.isEmpty) {
      return currentRequests;
    }
    final filtered = currentRequests.where((req) => req.tripId == tripId).toList();
    return filtered.isNotEmpty ? List.unmodifiable(filtered) : currentRequests;
  }

  int getPendingRequestCount(String? tripId) {
    return getRequestsForTrip(tripId).where((req) => req.status == 'PENDING').length;
  }

  int getTotalRequestCount() {
    return requests.length;
  }

  void addRequest(ParcelRequest request) {
    _dynamicRequests.insert(0, request);
  }

  void updateRequestStatus(String requestId, String newStatus) {
    final index = _dynamicRequests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      _dynamicRequests[index].status = newStatus;
    }

    // Sync status back to SenderMockBookingData single source of truth
    SenderDeliveryStatus sStatus = SenderDeliveryStatus.pending;
    if (newStatus == 'ACCEPTED') {
      sStatus = SenderDeliveryStatus.accepted;
    } else if (newStatus == 'PICKED_UP' || newStatus == 'IN_TRANSIT') {
      sStatus = SenderDeliveryStatus.inTransit;
    } else if (newStatus == 'DELIVERED') {
      sStatus = SenderDeliveryStatus.delivered;
    } else if (newStatus == 'REJECTED' || newStatus == 'CANCELLED') {
      sStatus = SenderDeliveryStatus.cancelled;
    }

    SenderMockBookingData.updateBookingStatus(requestId, sStatus);
  }
}
