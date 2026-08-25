import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/sender/models/sender_mock_delivery_data.dart';
import 'package:frontend/features/sender/screens/sender_delivery_requests_screen.dart';
import 'package:frontend/features/sender/screens/sender_delivery_status_screen.dart';
import 'package:frontend/features/sender/widgets/sender_delivery_request_card.dart';

void main() {
  final mockRequests = SenderMockDeliveryData.getMockDeliveryRequests();

  testWidgets('TEST 7: Delivery request list displays multiple requests', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryRequestsScreen(items: mockRequests),
      ),
    );

    expect(find.byType(SenderDeliveryRequestCard), findsNWidgets(mockRequests.length));
    expect(find.text('Arun'), findsOneWidget);
    expect(find.text('Bala'), findsOneWidget);
  });

  testWidgets('TEST 8: Empty request list displays "No delivery requests"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryRequestsScreen(items: []),
      ),
    );

    expect(find.text('No bookings yet'), findsOneWidget);
    expect(find.text('Your delivery requests will appear here.'), findsOneWidget);
    expect(find.text('Search Travellers'), findsOneWidget);
  });

  testWidgets('TEST 9: Error state displays retry UI', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryRequestsScreen(
          errorMessage: 'Network timeout',
          onRetry: () {
            retried = true;
          },
        ),
      ),
    );

    expect(find.text('Unable to load delivery requests'), findsOneWidget);
    expect(find.text('Network timeout'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(retried, isTrue);
  });

  testWidgets('TEST 10: Loading state displays progress indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SenderDeliveryRequestsScreen(isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TEST 11: Tapping "View Details" opens SenderDeliveryStatusScreen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenderDeliveryRequestsScreen(items: [mockRequests.first]),
      ),
    );

    final viewDetailsButton = find.text('View Details').first;
    await tester.ensureVisible(viewDetailsButton);
    await tester.tap(viewDetailsButton);
    await tester.pumpAndSettle();

    expect(find.byType(SenderDeliveryStatusScreen), findsOneWidget);
  });
}
