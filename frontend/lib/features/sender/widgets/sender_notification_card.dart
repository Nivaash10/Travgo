import 'package:flutter/material.dart';
import '../models/sender_notification.dart';

/// Reusable card widget for displaying a single Sender notification item.
class SenderNotificationCard extends StatelessWidget {
  final SenderNotification notification;
  final VoidCallback onTap;

  const SenderNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  IconData _getNotificationIcon(SenderNotificationType type) {
    switch (type) {
      case SenderNotificationType.requestSubmitted:
        return Icons.receipt_long;
      case SenderNotificationType.travellerAccepted:
        return Icons.check_circle_outline;
      case SenderNotificationType.travellerRejected:
        return Icons.cancel_outlined;
      case SenderNotificationType.travellerCancelled:
        return Icons.person_off_outlined;
      case SenderNotificationType.pickupReminder:
        return Icons.schedule;
      case SenderNotificationType.parcelPickedUp:
        return Icons.inventory_2_outlined;
      case SenderNotificationType.parcelInTransit:
        return Icons.local_shipping_outlined;
      case SenderNotificationType.parcelArrived:
        return Icons.location_on_outlined;
      case SenderNotificationType.parcelDelivered:
        return Icons.mark_email_read_outlined;
      case SenderNotificationType.deliveryCompleted:
        return Icons.verified_outlined;
      case SenderNotificationType.general:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(BuildContext context, SenderNotificationType type) {
    final theme = Theme.of(context);
    switch (type) {
      case SenderNotificationType.travellerAccepted:
      case SenderNotificationType.parcelDelivered:
      case SenderNotificationType.deliveryCompleted:
        return Colors.green[700]!;
      case SenderNotificationType.travellerRejected:
      case SenderNotificationType.travellerCancelled:
        return Colors.red[700]!;
      case SenderNotificationType.pickupReminder:
        return Colors.orange[800]!;
      case SenderNotificationType.parcelInTransit:
      case SenderNotificationType.parcelPickedUp:
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Card(
      elevation: isUnread ? 2 : 1,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      color: isUnread ? theme.colorScheme.primaryContainer.withAlpha(40) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread
            ? BorderSide(color: theme.colorScheme.primary.withAlpha(100), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(context, notification.type).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getIconColor(context, notification.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUnread ? Colors.black87 : Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                    if (notification.route != null ||
                        notification.travellerName != null) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (notification.travellerName != null)
                            Text(
                              'Traveller: ${notification.travellerName}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (notification.route != null)
                            Text(
                              '(${notification.route})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
