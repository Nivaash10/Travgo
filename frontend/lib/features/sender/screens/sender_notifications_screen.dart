import 'package:flutter/material.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_delivery_status.dart';
import '../models/sender_notification.dart';
import '../models/sender_search_query.dart';
import '../models/sender_traveller_match.dart';
import '../widgets/sender_notification_card.dart';
import 'sender_delivery_status_screen.dart';

/// Screen displaying the list of Sender notifications and delivery activity updates.
class SenderNotificationsScreen extends StatefulWidget {
  final List<SenderNotification> initialNotifications;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SenderNotificationsScreen({
    super.key,
    this.initialNotifications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<SenderNotificationsScreen> createState() =>
      _SenderNotificationsScreenState();
}

class _SenderNotificationsScreenState extends State<SenderNotificationsScreen> {
  late List<SenderNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.initialNotifications);
    _sortNotifications();
  }

  void _sortNotifications() {
    _notifications.sort((a, b) {
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1; // Unread first
      }
      return b.timestamp.compareTo(a.timestamp); // Newest first
    });
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(int index) {
    if (!_notifications[index].isRead) {
      setState(() {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _sortNotifications();
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _sortNotifications();
    });
  }

  void _onNotificationTapped(SenderNotification notification, int index) {
    _markAsRead(index);

    // If notification has an associated request/status, open SenderDeliveryStatusScreen
    if (notification.requestId != null) {
      final statusItem = _mapNotificationToStatusItem(notification);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SenderDeliveryStatusScreen(
            statusItem: statusItem,
          ),
        ),
      );
    }
  }

  SenderDeliveryStatusItem _mapNotificationToStatusItem(SenderNotification n) {
    SenderDeliveryStatus status;
    switch (n.type) {
      case SenderNotificationType.requestSubmitted:
        status = SenderDeliveryStatus.pending;
        break;
      case SenderNotificationType.travellerAccepted:
        status = SenderDeliveryStatus.accepted;
        break;
      case SenderNotificationType.travellerRejected:
        status = SenderDeliveryStatus.rejected;
        break;
      case SenderNotificationType.travellerCancelled:
        status = SenderDeliveryStatus.cancelled;
        break;
      case SenderNotificationType.pickupReminder:
        status = SenderDeliveryStatus.pickupPending;
        break;
      case SenderNotificationType.parcelPickedUp:
        status = SenderDeliveryStatus.pickedUp;
        break;
      case SenderNotificationType.parcelInTransit:
        status = SenderDeliveryStatus.inTransit;
        break;
      case SenderNotificationType.parcelArrived:
      case SenderNotificationType.parcelDelivered:
      case SenderNotificationType.deliveryCompleted:
        status = SenderDeliveryStatus.delivered;
        break;
      default:
        status = SenderDeliveryStatus.pending;
    }

    return SenderDeliveryStatusItem(
      requestId: n.requestId ?? 'REQ-101',
      status: status,
      createdAt: n.timestamp,
      statusMessage: n.message,
      request: SenderDeliveryRequest(
        searchQuery: SenderSearchQuery(
          source: n.route?.split('→').first.trim() ?? 'Coimbatore',
          destination: n.route?.split('→').last.trim() ?? 'Chennai',
          date: n.timestamp,
          parcelWeightKg: 2.5,
        ),
        traveller: SenderTravellerMatch(
          travellerName: n.travellerName ?? 'Arun',
          isVerified: true,
          route: n.route ?? 'Coimbatore → Chennai',
          travelDateTime: 'Today • 8:30 AM',
          availableCapacityKg: 5.0,
          priceRupees: 100.0,
          rating: 4.7,
        ),
        parcelDescription: 'Parcel delivery request',
        parcelWeightKg: 2.5,
        parcelCategory: 'Documents',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _unreadCount > 0 ? _markAllAsRead : null,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Unread Count Bar
            if (!widget.isLoading &&
                widget.errorMessage == null &&
                _notifications.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_unreadCount unread',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _unreadCount > 0
                            ? theme.colorScheme.primary
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            // Content Area
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Loading State
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 2. Error State
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Unable to load notifications',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 56, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No notifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You're all caught up. New delivery updates will appear here.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Populated List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return SenderNotificationCard(
          notification: notification,
          onTap: () => _onNotificationTapped(notification, index),
        );
      },
    );
  }
}
