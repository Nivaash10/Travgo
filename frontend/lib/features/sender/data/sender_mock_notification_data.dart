import '../models/sender_notification.dart';

/// Isolated frontend-only mock dataset for Sender notifications.
class SenderMockNotificationData {
  static List<SenderNotification> getMockNotifications() {
    final now = DateTime.now();

    return [
      // 1. Delivery Request Submitted
      SenderNotification(
        id: 'NOTIF-1',
        title: 'Delivery Request Submitted',
        message: 'Your delivery request to Chennai has been submitted to Arun.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        type: SenderNotificationType.requestSubmitted,
        isRead: false,
        requestId: 'REQ-101',
        route: 'Coimbatore → Chennai',
        travellerName: 'Arun',
      ),

      // 2. Traveller Accepted
      SenderNotification(
        id: 'NOTIF-2',
        title: 'Traveller Accepted',
        message: 'Arun accepted your delivery request from Coimbatore to Chennai.',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: SenderNotificationType.travellerAccepted,
        isRead: false,
        requestId: 'REQ-102',
        route: 'Coimbatore → Chennai',
        travellerName: 'Arun',
      ),

      // 3. Parcel Pickup Reminder
      SenderNotification(
        id: 'NOTIF-3',
        title: 'Parcel Pickup Reminder',
        message: 'Your parcel is scheduled for pickup today.',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: SenderNotificationType.pickupReminder,
        isRead: false,
        requestId: 'REQ-103',
        route: 'Coimbatore → Bangalore',
        travellerName: 'Karthik',
      ),

      // 4. Parcel Picked Up
      SenderNotification(
        id: 'NOTIF-4',
        title: 'Parcel Picked Up',
        message: 'Your parcel has been picked up and is now in transit.',
        timestamp: now.subtract(const Duration(days: 1)),
        type: SenderNotificationType.parcelPickedUp,
        isRead: true,
        requestId: 'REQ-103',
        route: 'Coimbatore → Bangalore',
        travellerName: 'Karthik',
      ),

      // 5. Parcel Delivered
      SenderNotification(
        id: 'NOTIF-5',
        title: 'Parcel Delivered',
        message: 'Your parcel has been delivered successfully.',
        timestamp: now.subtract(const Duration(days: 3)),
        type: SenderNotificationType.parcelDelivered,
        isRead: true,
        requestId: 'REQ-104',
        route: 'Chennai → Coimbatore',
        travellerName: 'Ravi',
      ),
    ];
  }
}
