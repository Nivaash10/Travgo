import '../models/sender_booking.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_delivery_status.dart';
import '../models/sender_search_query.dart';
import '../models/sender_traveller_match.dart';

/// Isolated frontend-only mock dataset for Sender bookings.
class SenderMockBookingData {
  static List<SenderBooking> getMockBookings() {
    final now = DateTime.now();

    return [
      // 1. Pending Booking
      SenderBooking(
        id: 'BKG-101',
        status: SenderDeliveryStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        deliveryPrice: 100.0,
        canCancel: true,
        canViewStatus: true,
        pickupLocation: 'Coimbatore Railway Station',
        deliveryLocation: 'Chennai Central',
        travellerName: 'Arun',
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
            route: 'Coimbatore â†’ Chennai',
            travelDateTime: '25 Aug 2026 â€¢ 8:30 AM',
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

      // 2. Accepted Booking
      SenderBooking(
        id: 'BKG-102',
        status: SenderDeliveryStatus.accepted,
        createdAt: now.subtract(const Duration(days: 1)),
        deliveryPrice: 150.0,
        canCancel: true,
        canViewStatus: true,
        pickupLocation: 'Gandhipuram Bus Stand',
        deliveryLocation: 'Koyambedu, Chennai',
        travellerName: 'Bala',
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
            route: 'Coimbatore â†’ Chennai',
            travelDateTime: '26 Aug 2026 â€¢ 10:00 AM',
            availableCapacityKg: 8.0,
            priceRupees: 150.0,
            rating: 4.5,
          ),
          parcelDescription: 'Clothes and shoes',
          parcelWeightKg: 3.0,
          parcelCategory: 'Clothes',
        ),
      ),

      // 3. Pickup Pending Booking
      SenderBooking(
        id: 'BKG-103',
        status: SenderDeliveryStatus.pickupPending,
        createdAt: now.subtract(const Duration(hours: 12)),
        deliveryPrice: 200.0,
        canCancel: true,
        canViewStatus: true,
        scheduledPickupDate: now.add(const Duration(hours: 4)),
        pickupLocation: 'Coimbatore Airport',
        deliveryLocation: 'Indiranagar, Bangalore',
        travellerName: 'Karthik',
        request: SenderDeliveryRequest(
          searchQuery: SenderSearchQuery(
            source: 'Coimbatore',
            destination: 'Bangalore',
            date: now,
            parcelWeightKg: 2.0,
          ),
          traveller: const SenderTravellerMatch(
            travellerName: 'Karthik',
            isVerified: true,
            route: 'Coimbatore â†’ Bangalore',
            travelDateTime: 'Today â€¢ 6:00 PM',
            availableCapacityKg: 6.0,
            priceRupees: 200.0,
            rating: 4.9,
          ),
          parcelDescription: 'Laptop accessories',
          parcelWeightKg: 2.0,
          parcelCategory: 'Electronics',
        ),
      ),

      // 4. In Transit Booking
      SenderBooking(
        id: 'BKG-104',
        status: SenderDeliveryStatus.inTransit,
        createdAt: now.subtract(const Duration(days: 2)),
        deliveryPrice: 250.0,
        canCancel: false,
        canViewStatus: true,
        pickupLocation: 'Coimbatore Town',
        deliveryLocation: 'Majestic, Bangalore',
        travellerName: 'Karthik',
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
            route: 'Coimbatore â†’ Bangalore',
            travelDateTime: 'Today â€¢ 6:00 AM',
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

      // 5. Delivered Booking
      SenderBooking(
        id: 'BKG-105',
        status: SenderDeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 5)),
        deliveryPrice: 180.0,
        canCancel: false,
        canViewStatus: true,
        pickupLocation: 'T. Nagar, Chennai',
        deliveryLocation: 'Peelamedu, Coimbatore',
        travellerName: 'Ravi',
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
            route: 'Chennai â†’ Coimbatore',
            travelDateTime: '20 Aug 2026 â€¢ 4:00 PM',
            availableCapacityKg: 10.0,
            priceRupees: 180.0,
            rating: 4.8,
          ),
          parcelDescription: 'Home food items',
          parcelWeightKg: 4.0,
          parcelCategory: 'Food',
        ),
      ),

      // 6. Cancelled Booking
      SenderBooking(
        id: 'BKG-106',
        status: SenderDeliveryStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 3)),
        deliveryPrice: 90.0,
        canCancel: false,
        canViewStatus: false,
        pickupLocation: 'Coimbatore Junction',
        deliveryLocation: 'Salem Bus Stand',
        travellerName: 'Suresh',
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
            route: 'Coimbatore â†’ Salem',
            travelDateTime: '22 Aug 2026 â€¢ 1:00 PM',
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
