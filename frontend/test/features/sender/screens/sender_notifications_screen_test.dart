import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_notification_data.dart';
import 'package:frontend/features/sender/models/sender_notification.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';
import 'package:frontend/features/sender/widgets/sender_notification_card.dart';

void main() {
  final mockNotifs = SenderMockNotificationData.getMockNotifications();

  test('TEST 1: Notification model can be created correctly', () {
    final now = DateTime.now();
    final notif = SenderNotification(
      id: 'N-1',
      title: 'Test Notification',
      message: 'Test message body',
      timestamp: now,
      type: SenderNotificationType.requestSubmitted,
      isRead: false,
    );

    expect(notif.id, equals('N-1'));
    expect(notif.title, equals('Test Notification'));
    expect(notif.message, equals('Test message body'));
    expect(notif.type, equals(SenderNotificationType.requestSubmitted));
    expect(notif.isRead, isFalse);

    final updated = notif.copyWith(isRead: true);
    expect(updated.isRead, isTrue);
    expect(updated.id, equals('N-1'));
  });

  testWidgets('TEST 2: Notifications screen displays notification title and message', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: mockNotifs),
      ),
    );

    expect(find.text('Delivery Request Submitted'), findsOneWidget);
    expect(find.text('Your delivery request to Chennai has been submitted to Arun.'), findsOneWidget);
  });

  testWidgets('TEST 3: Unread notifications are visually distinguishable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: mockNotifs),
      ),
    );

    final unreadCards = tester.widgetList<SenderNotificationCard>(
      find.byType(SenderNotificationCard),
    ).where((card) => !card.notification.isRead);

    expect(unreadCards.isNotEmpty, isTrue);
  });

  testWidgets('TEST 4: Unread count is displayed correctly', (tester) async {
    final unreadCount = mockNotifs.where((n) => !n.isRead).length;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: mockNotifs),
      ),
    );

    expect(find.text('$unreadCount unread'), findsOneWidget);
  });

  testWidgets('TEST 5: Tapping a notification marks it as read', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(
          initialNotifications: [
            SenderNotification(
              id: 'N-5',
              title: 'Unread Alert',
              message: 'Unread message details',
              timestamp: DateTime.now(),
              type: SenderNotificationType.general,
              isRead: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('1 unread'), findsOneWidget);

    await tester.tap(find.text('Unread Alert'));
    await tester.pumpAndSettle();

    expect(find.text('0 unread'), findsOneWidget);
  });

  testWidgets('TEST 6: "Mark all as read" marks every notification as read', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: mockNotifs),
      ),
    );

    final markAllButton = find.text('Mark all as read');
    expect(markAllButton, findsOneWidget);

    await tester.tap(markAllButton);
    await tester.pumpAndSettle();

    expect(find.text('0 unread'), findsOneWidget);
  });

  testWidgets('TEST 7: Empty notification list displays "No notifications"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: []),
      ),
    );

    expect(find.text('No notifications'), findsOneWidget);
    expect(
      find.text("You're all caught up. New delivery updates will appear here."),
      findsOneWidget,
    );
  });

  testWidgets('TEST 8: Multiple notification types display correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: mockNotifs),
      ),
    );

    expect(find.byType(SenderNotificationCard), findsNWidgets(mockNotifs.length));
  });

  testWidgets('TEST 9: Notifications are ordered newest first', (tester) async {
    final now = DateTime.now();
    final older = SenderNotification(
      id: 'N-OLD',
      title: 'Older Notification',
      message: 'Old content',
      timestamp: now.subtract(const Duration(hours: 5)),
      type: SenderNotificationType.general,
      isRead: false,
    );
    final newer = SenderNotification(
      id: 'N-NEW',
      title: 'Newer Notification',
      message: 'New content',
      timestamp: now.subtract(const Duration(minutes: 5)),
      type: SenderNotificationType.general,
      isRead: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(initialNotifications: [older, newer]),
      ),
    );

    final cards = tester.widgetList<SenderNotificationCard>(
      find.byType(SenderNotificationCard),
    ).toList();

    expect(cards.first.notification.id, equals('N-NEW'));
    expect(cards.last.notification.id, equals('N-OLD'));
  });

  testWidgets('TEST 10: Sender dashboard notification entry point opens notifications screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDashboardScreen(),
      ),
    );

    final notificationIconButton = find.byIcon(Icons.notifications_none);
    expect(notificationIconButton, findsOneWidget);

    await tester.tap(notificationIconButton);
    await tester.pumpAndSettle();

    expect(find.byType(SenderNotificationsScreen), findsOneWidget);
  });
}
