import '../models/sender_tracking.dart';

/// Isolated frontend-only mock dataset for Sender live delivery tracking.
///
/// Frontend-only mock data. Official API/backend mapping will be provided by Person 1.
class SenderMockTrackingData {
  static List<SenderTracking> getMockTrackings() {
    final now = DateTime.now();

    return [
      // 1. Accepted / Awaiting Pickup
      SenderTracking(
        requestId: 'REQ-101',
        bookingId: 'BKG-101',
        currentStatus: SenderTrackingStatus.accepted,
        statusMessage: 'Traveller accepted your request. Awaiting pickup schedule.',
        source: 'Coimbatore',
        destination: 'Chennai',
        travellerName: 'Arun',
        travellerVerified: true,
        travelDateTime: 'Today â€¢ 8:30 AM',
        estimatedArrival: 'Today â€¢ 6:00 PM',
        currentLocation: 'Coimbatore Pickup Point',
        lastUpdated: now.subtract(const Duration(minutes: 30)),
        progressPercentage: 0.2,
        events: [
          SenderTrackingEvent(
            id: 'EVT-101-1',
            title: 'Delivery Request Submitted',
            message: 'Request created for Coimbatore to Chennai.',
            timestamp: now.subtract(const Duration(hours: 2)),
            status: SenderTrackingStatus.pending,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-101-2',
            title: 'Traveller Accepted',
            message: 'Arun has accepted your delivery request.',
            timestamp: now.subtract(const Duration(minutes: 30)),
            status: SenderTrackingStatus.accepted,
            isCompleted: true,
            isCurrent: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-101-3',
            title: 'Parcel Pickup',
            message: 'Traveller will collect parcel at pickup location.',
            timestamp: now.add(const Duration(minutes: 30)),
            status: SenderTrackingStatus.pickupPending,
          ),
          SenderTrackingEvent(
            id: 'EVT-101-4',
            title: 'In Transit',
            message: 'Parcel on the way to destination.',
            timestamp: now.add(const Duration(hours: 3)),
            status: SenderTrackingStatus.inTransit,
          ),
          SenderTrackingEvent(
            id: 'EVT-101-5',
            title: 'Delivered',
            message: 'Parcel safely delivered to recipient.',
            timestamp: now.add(const Duration(hours: 8)),
            status: SenderTrackingStatus.delivered,
          ),
        ],
      ),

      // 2. Parcel Picked Up
      SenderTracking(
        requestId: 'REQ-102',
        bookingId: 'BKG-102',
        currentStatus: SenderTrackingStatus.pickedUp,
        statusMessage: 'Parcel picked up by Bala. Travel starting soon.',
        source: 'Coimbatore',
        destination: 'Bangalore',
        travellerName: 'Bala',
        travellerVerified: true,
        travelDateTime: 'Today â€¢ 10:00 AM',
        estimatedArrival: 'Today â€¢ 5:00 PM',
        currentLocation: 'Coimbatore Gandhipuram Hub',
        lastUpdated: now.subtract(const Duration(minutes: 15)),
        progressPercentage: 0.4,
        events: [
          SenderTrackingEvent(
            id: 'EVT-102-1',
            title: 'Delivery Request Submitted',
            message: 'Request created for Coimbatore to Bangalore.',
            timestamp: now.subtract(const Duration(hours: 3)),
            status: SenderTrackingStatus.pending,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-102-2',
            title: 'Traveller Accepted',
            message: 'Bala accepted your delivery request.',
            timestamp: now.subtract(const Duration(hours: 1)),
            status: SenderTrackingStatus.accepted,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-102-3',
            title: 'Parcel Picked Up',
            message: 'Parcel collected from Coimbatore Gandhipuram.',
            timestamp: now.subtract(const Duration(minutes: 15)),
            status: SenderTrackingStatus.pickedUp,
            isCompleted: true,
            isCurrent: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-102-4',
            title: 'In Transit',
            message: 'En route to Bangalore via Hosur highway.',
            timestamp: now.add(const Duration(hours: 2)),
            status: SenderTrackingStatus.inTransit,
          ),
          SenderTrackingEvent(
            id: 'EVT-102-5',
            title: 'Delivered',
            message: 'Parcel delivered to recipient in Bangalore.',
            timestamp: now.add(const Duration(hours: 5)),
            status: SenderTrackingStatus.delivered,
          ),
        ],
      ),

      // 3. In Transit
      SenderTracking(
        requestId: 'REQ-103',
        bookingId: 'BKG-103',
        currentStatus: SenderTrackingStatus.inTransit,
        statusMessage: 'Parcel in transit with Karthik near Salem Bypass.',
        source: 'Coimbatore',
        destination: 'Chennai',
        travellerName: 'Karthik',
        travellerVerified: true,
        travelDateTime: 'Today â€¢ 6:00 AM',
        estimatedArrival: 'Today â€¢ 4:30 PM',
        currentLocation: 'Salem Highway Bypass',
        lastUpdated: now.subtract(const Duration(minutes: 5)),
        progressPercentage: 0.65,
        events: [
          SenderTrackingEvent(
            id: 'EVT-103-1',
            title: 'Delivery Request Submitted',
            message: 'Request created for Coimbatore to Chennai.',
            timestamp: now.subtract(const Duration(hours: 6)),
            status: SenderTrackingStatus.pending,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-103-2',
            title: 'Traveller Accepted',
            message: 'Karthik accepted the request.',
            timestamp: now.subtract(const Duration(hours: 5)),
            status: SenderTrackingStatus.accepted,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-103-3',
            title: 'Parcel Picked Up',
            message: 'Picked up from Coimbatore station.',
            timestamp: now.subtract(const Duration(hours: 4)),
            status: SenderTrackingStatus.pickedUp,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-103-4',
            title: 'In Transit',
            message: 'Currently passing Salem Bypass towards Villupuram.',
            timestamp: now.subtract(const Duration(minutes: 5)),
            status: SenderTrackingStatus.inTransit,
            isCompleted: true,
            isCurrent: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-103-5',
            title: 'Arrived at Destination',
            message: 'Arriving at Chennai Koyambedu.',
            timestamp: now.add(const Duration(hours: 2)),
            status: SenderTrackingStatus.arrived,
          ),
          SenderTrackingEvent(
            id: 'EVT-103-6',
            title: 'Delivered',
            message: 'Handed over to recipient.',
            timestamp: now.add(const Duration(hours: 3)),
            status: SenderTrackingStatus.delivered,
          ),
        ],
      ),

      // 4. Arrived at Destination
      SenderTracking(
        requestId: 'REQ-104',
        bookingId: 'BKG-104',
        currentStatus: SenderTrackingStatus.arrived,
        statusMessage: 'Traveller has arrived at Chennai Koyambedu.',
        source: 'Coimbatore',
        destination: 'Chennai',
        travellerName: 'Karthik',
        travellerVerified: true,
        travelDateTime: 'Today â€¢ 6:00 AM',
        estimatedArrival: 'Arrived â€¢ Handover in progress',
        currentLocation: 'Chennai Koyambedu Hub',
        lastUpdated: now.subtract(const Duration(minutes: 2)),
        progressPercentage: 0.9,
        events: [
          SenderTrackingEvent(
            id: 'EVT-104-1',
            title: 'Delivery Request Submitted',
            message: 'Request created.',
            timestamp: now.subtract(const Duration(hours: 7)),
            status: SenderTrackingStatus.pending,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-104-2',
            title: 'In Transit',
            message: 'Completed highway transit.',
            timestamp: now.subtract(const Duration(hours: 1)),
            status: SenderTrackingStatus.inTransit,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-104-3',
            title: 'Arrived at Destination',
            message: 'Arrived at Chennai Koyambedu Hub.',
            timestamp: now.subtract(const Duration(minutes: 2)),
            status: SenderTrackingStatus.arrived,
            isCompleted: true,
            isCurrent: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-104-4',
            title: 'Delivered',
            message: 'Handover to recipient pending OTP.',
            timestamp: now.add(const Duration(minutes: 10)),
            status: SenderTrackingStatus.delivered,
          ),
        ],
      ),

      // 5. Delivered
      SenderTracking(
        requestId: 'REQ-105',
        bookingId: 'BKG-105',
        currentStatus: SenderTrackingStatus.delivered,
        statusMessage: 'Parcel successfully delivered to recipient.',
        source: 'Chennai',
        destination: 'Coimbatore',
        travellerName: 'Ravi',
        travellerVerified: true,
        travelDateTime: 'Yesterday â€¢ 4:00 PM',
        estimatedArrival: 'Delivered Yesterday',
        currentLocation: 'Coimbatore RS Puram',
        lastUpdated: now.subtract(const Duration(days: 1)),
        progressPercentage: 1.0,
        events: [
          SenderTrackingEvent(
            id: 'EVT-105-1',
            title: 'Delivery Request Submitted',
            message: 'Request created for Chennai to Coimbatore.',
            timestamp: now.subtract(const Duration(days: 1, hours: 8)),
            status: SenderTrackingStatus.pending,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-105-2',
            title: 'Parcel Picked Up',
            message: 'Picked up from Chennai Central.',
            timestamp: now.subtract(const Duration(days: 1, hours: 6)),
            status: SenderTrackingStatus.pickedUp,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-105-3',
            title: 'In Transit',
            message: 'Travelled via Salem to Coimbatore.',
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
            status: SenderTrackingStatus.inTransit,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-105-4',
            title: 'Delivered',
            message: 'Parcel delivered to recipient at RS Puram.',
            timestamp: now.subtract(const Duration(days: 1)),
            status: SenderTrackingStatus.delivered,
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),

      // 6. Cancelled
      SenderTracking(
        requestId: 'REQ-106',
        bookingId: 'BKG-106',
        currentStatus: SenderTrackingStatus.cancelled,
        statusMessage: 'Delivery request was cancelled.',
        source: 'Coimbatore',
        destination: 'Bangalore',
        travellerName: 'Suresh',
        travellerVerified: false,
        travelDateTime: 'Today â€¢ 7:00 AM',
        estimatedArrival: 'Cancelled',
        currentLocation: 'Coimbatore',
        lastUpdated: now.subtract(const Duration(hours: 4)),
        progressPercentage: 0.0,
        events: [
          SenderTrackingEvent(
            id: 'EVT-106-1',
            title: 'Delivery Request Submitted',
            message: 'Request submitted.',
            timestamp: now.subtract(const Duration(hours: 5)),
            status: SenderTrackingStatus.pending,
            isCompleted: true,
          ),
          SenderTrackingEvent(
            id: 'EVT-106-2',
            title: 'Request Cancelled',
            message: 'Delivery request was cancelled by sender.',
            timestamp: now.subtract(const Duration(hours: 4)),
            status: SenderTrackingStatus.cancelled,
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
    ];
  }

  static SenderTracking getTracking(String identifier) {
    final list = getMockTrackings();
    final match = list.where((t) => t.bookingId == identifier || t.requestId == identifier).firstOrNull;

    if (match != null) return match;

    // Fallback default
    final now = DateTime.now();
    return SenderTracking(
      requestId: 'REQ-$identifier',
      bookingId: identifier.startsWith('BKG-') ? identifier : 'BKG-$identifier',
      currentStatus: SenderTrackingStatus.inTransit,
      statusMessage: 'Parcel in transit with traveller.',
      source: 'Coimbatore',
      destination: 'Chennai',
      travellerName: 'Arun',
      travellerVerified: true,
      travelDateTime: 'Today â€¢ 8:30 AM',
      estimatedArrival: 'Today â€¢ 6:30 PM',
      currentLocation: 'Salem Highway',
      lastUpdated: now,
      progressPercentage: 0.6,
      events: [
        SenderTrackingEvent(
          id: 'EVT-DEF-1',
          title: 'Delivery Request Submitted',
          message: 'Request created.',
          timestamp: now.subtract(const Duration(hours: 4)),
          status: SenderTrackingStatus.pending,
          isCompleted: true,
        ),
        SenderTrackingEvent(
          id: 'EVT-DEF-2',
          title: 'In Transit',
          message: 'En route on Salem Highway.',
          timestamp: now,
          status: SenderTrackingStatus.inTransit,
          isCompleted: true,
          isCurrent: true,
        ),
      ],
    );
  }
}
