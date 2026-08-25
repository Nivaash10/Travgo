import 'sender_delivery_request.dart';
import 'sender_delivery_status.dart';
import 'sender_search_query.dart';
import 'sender_traveller_match.dart';

/// Isolated frontend-only mock dataset for presentation testing.
class SenderMockDeliveryData {
  static List<SenderDeliveryStatusItem> getMockDeliveryRequests() {
    final now = DateTime.now();

    return [
      // Request 1: Pending
      SenderDeliveryStatusItem(
        requestId: 'REQ-101',
        status: SenderDeliveryStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        statusMessage: 'Waiting for traveller acceptance.',
        request: SenderDeliveryRequest(
          searchQuery: SenderSearchQuery(
            source: 'Coimbatore',
            destination: 'Chennai',
            date: now.add(const Duration(days: 1)),
            parcelWeightKg: 2.5,
          ),
          traveller: const SenderTravellerMatch(
            travellerName: 'Arun',
            isVerified: true,
            route: 'Coimbatore → Chennai',
            travelDateTime: '25 Aug 2026 • 8:30 AM',
            availableCapacityKg: 5.0,
            priceRupees: 100.0,
            rating: 4.7,
          ),
          parcelDescription: 'Books and documents',
          parcelWeightKg: 2.5,
          parcelCategory: 'Documents',
          specialInstructions: 'Handle with care',
        ),
      ),

      // Request 2: Accepted
      SenderDeliveryStatusItem(
        requestId: 'REQ-102',
        status: SenderDeliveryStatus.accepted,
        travellerAccepted: true,
        createdAt: now.subtract(const Duration(days: 1)),
        statusMessage: 'Traveller has accepted your delivery request.',
        request: SenderDeliveryRequest(
          searchQuery: SenderSearchQuery(
            source: 'Coimbatore',
            destination: 'Chennai',
            date: now.add(const Duration(days: 2)),
            parcelWeightKg: 3.0,
          ),
          traveller: const SenderTravellerMatch(
            travellerName: 'Bala',
            isVerified: false,
            route: 'Coimbatore → Chennai',
            travelDateTime: '26 Aug 2026 • 10:00 AM',
            availableCapacityKg: 8.0,
            priceRupees: 150.0,
            rating: 4.5,
          ),
          parcelDescription: 'Clothes and shoes',
          parcelWeightKg: 3.0,
          parcelCategory: 'Clothes',
        ),
      ),

      // Request 3: In Transit
      SenderDeliveryStatusItem(
        requestId: 'REQ-103',
        status: SenderDeliveryStatus.inTransit,
        travellerAccepted: true,
        parcelPickedUp: true,
        progress: 0.6,
        createdAt: now.subtract(const Duration(days: 2)),
        statusMessage: 'Your parcel is currently in transit.',
        request: SenderDeliveryRequest(
          searchQuery: SenderSearchQuery(
            source: 'Coimbatore',
            destination: 'Bangalore',
            date: now,
            parcelWeightKg: 1.5,
          ),
          traveller: const SenderTravellerMatch(
            travellerName: 'Karthik',
            isVerified: true,
            route: 'Coimbatore → Bangalore',
            travelDateTime: '24 Aug 2026 • 6:00 AM',
            availableCapacityKg: 6.0,
            priceRupees: 250.0,
            rating: 4.9,
          ),
          parcelDescription: 'Electronic gadgets',
          parcelWeightKg: 1.5,
          parcelCategory: 'Electronics',
          specialInstructions: 'Fragile content',
        ),
      ),

      // Request 4: Delivered
      SenderDeliveryStatusItem(
        requestId: 'REQ-104',
        status: SenderDeliveryStatus.delivered,
        travellerAccepted: true,
        parcelPickedUp: true,
        delivered: true,
        progress: 1.0,
        createdAt: now.subtract(const Duration(days: 5)),
        statusMessage: 'Parcel has been delivered successfully.',
        request: SenderDeliveryRequest(
          searchQuery: SenderSearchQuery(
            source: 'Chennai',
            destination: 'Coimbatore',
            date: now.subtract(const Duration(days: 4)),
            parcelWeightKg: 4.0,
          ),
          traveller: const SenderTravellerMatch(
            travellerName: 'Ravi',
            isVerified: true,
            route: 'Chennai → Coimbatore',
            travelDateTime: '20 Aug 2026 • 4:00 PM',
            availableCapacityKg: 10.0,
            priceRupees: 180.0,
            rating: 4.8,
          ),
          parcelDescription: 'Home food items',
          parcelWeightKg: 4.0,
          parcelCategory: 'Food',
        ),
      ),

      // Request 5: Rejected
      SenderDeliveryStatusItem(
        requestId: 'REQ-105',
        status: SenderDeliveryStatus.rejected,
        createdAt: now.subtract(const Duration(days: 3)),
        statusMessage: 'Traveller declined this request.',
        request: SenderDeliveryRequest(
          searchQuery: SenderSearchQuery(
            source: 'Coimbatore',
            destination: 'Salem',
            date: now.subtract(const Duration(days: 2)),
            parcelWeightKg: 5.0,
          ),
          traveller: const SenderTravellerMatch(
            travellerName: 'Suresh',
            isVerified: false,
            route: 'Coimbatore → Salem',
            travelDateTime: '22 Aug 2026 • 1:00 PM',
            availableCapacityKg: 5.0,
            priceRupees: 90.0,
            rating: null,
          ),
          parcelDescription: 'Heavy tools',
          parcelWeightKg: 5.0,
          parcelCategory: 'Other',
        ),
      ),
    ];
  }
}
