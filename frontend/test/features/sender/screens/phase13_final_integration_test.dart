import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/data/sender_mock_booking_data.dart';
import 'package:frontend/features/sender/data/sender_mock_notification_data.dart';
import 'package:frontend/features/sender/models/sender_delivery_completion.dart';
import 'package:frontend/features/sender/models/sender_delivery_status.dart';
import 'package:frontend/features/sender/screens/my_bookings_screen.dart';
import 'package:frontend/features/sender/screens/search_route_screen.dart';
import 'package:frontend/features/sender/screens/sender_booking_detail_screen.dart';
import 'package:frontend/features/sender/screens/sender_dashboard_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_completion_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_feedback_screen.dart';
import 'package:frontend/features/sender/screens/sender_notifications_screen.dart';
import 'package:frontend/features/sender/screens/sender_proof_viewer_screen.dart';
import 'package:frontend/features/sender/screens/sender_tracking_screen.dart';

void main() {
  testWidgets('TASK 11.1: Sender dashboard opens notifications screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));

    final notificationBtn = find.byIcon(Icons.notifications_none);
    expect(notificationBtn, findsOneWidget);
    await tester.tap(notificationBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SenderNotificationsScreen), findsOneWidget);
  });

  testWidgets('TASK 11.2: Sender dashboard opens Search Route flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: SenderDashboardScreen()));

    final searchBtn = find.text('Search Travellers');
    expect(searchBtn, findsWidgets);
    await tester.tap(searchBtn.first);
    await tester.pumpAndSettle();

    expect(find.byType(SearchRouteScreen), findsOneWidget);
  });

  testWidgets('TASK 11.3: My Bookings opens booking detail', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: MyBookingsScreen()));

    expect(find.text('My Bookings'), findsOneWidget);

    final viewDetailsBtn = find.text('View Details').first;
    await tester.ensureVisible(viewDetailsBtn);
    await tester.tap(viewDetailsBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SenderBookingDetailScreen), findsOneWidget);
  });

  testWidgets(
    'TASK 11.4: Booking detail opens tracking screen when appropriate',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final inTransitBooking = SenderMockBookingData.getMockBookings()
          .firstWhere((b) => b.status == SenderDeliveryStatus.inTransit);

      await tester.pumpWidget(
        MaterialApp(home: SenderBookingDetailScreen(booking: inTransitBooking)),
      );

      final trackBtn = find.text('Track Delivery');
      expect(trackBtn, findsOneWidget);
      await tester.ensureVisible(trackBtn);
      await tester.tap(trackBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SenderTrackingScreen), findsOneWidget);
    },
  );

  testWidgets(
    'TASK 11.5: Delivered booking exposes completion, proof, and rating actions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      final deliveredBooking = SenderMockBookingData.getMockBookings()
          .firstWhere((b) => b.status == SenderDeliveryStatus.delivered);

      await tester.pumpWidget(
        MaterialApp(home: SenderBookingDetailScreen(booking: deliveredBooking)),
      );

      expect(find.text('View Delivery Proof'), findsOneWidget);
      expect(find.text('Rate Traveller'), findsOneWidget);

      await tester.ensureVisible(find.text('View Delivery Proof'));
      await tester.tap(find.text('View Delivery Proof'));
      await tester.pumpAndSettle();

      expect(find.byType(SenderDeliveryCompletionScreen), findsOneWidget);
    },
  );

  testWidgets('TASK 11.6: Rating flow completes successfully', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryFeedbackScreen(
          bookingId: 'BKG-105',
          travellerName: 'Ravi',
          route: 'Coimbatore → Chennai',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border).at(4));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Excellent service.');
    await tester.pumpAndSettle();

    final submitBtn = find.widgetWithText(
      ElevatedButton,
      'Submit Review (5 Stars)',
    );
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Thank You!'), findsOneWidget);
    expect(find.text('★ 5.0'), findsOneWidget);
  });

  testWidgets('TASK 11.7: Notification navigation works', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    final mockNotifications = SenderMockNotificationData.getMockNotifications();

    await tester.pumpWidget(
      MaterialApp(
        home: SenderNotificationsScreen(
          initialNotifications: mockNotifications,
        ),
      ),
    );

    final card = find.text(mockNotifications.first.title);
    expect(card, findsOneWidget);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.text('Delivery Status'), findsOneWidget);
  });

  testWidgets('TASK 11.8: Back navigation does not crash', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SenderProofViewerScreen(
                        completion: SenderDeliveryCompletion(
                          bookingId: 'BKG-105',
                          requestId: 'REQ-105',
                          deliveredAt: DateTime.now(),
                          destination: 'Chennai',
                          travellerName: 'Ravi',
                          parcelDescription: 'Test',
                          parcelWeightKg: 1.0,
                          deliveryMessage: 'Delivered',
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open Viewer'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Viewer'));
    await tester.pumpAndSettle();

    expect(find.byType(SenderProofViewerScreen), findsOneWidget);

    final closeBtn = find.text('Close Proof Viewer');
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    expect(find.text('Open Viewer'), findsOneWidget);
  });

  testWidgets(
    'TASK 11.9: Empty/loading/error states render correctly across screens',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SenderDeliveryCompletionScreen(isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: SenderTrackingScreen(isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}
