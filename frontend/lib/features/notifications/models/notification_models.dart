/// Person 5 — Notifications module data model

enum NotificationType {
  booking,
  payment,
  pickup,
  transit,
  delivered,
  rating,
  payout,
}

class AppNotification {
  final NotificationType type;
  final String title;
  final String subtitle;
  final String time;
  final bool read;

  const AppNotification({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    this.read = false,
  });
}