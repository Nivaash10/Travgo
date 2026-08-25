import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/tracking/screens/tracking_screen.dart';
import 'package:frontend/features/otp/screens/pickup_otp_screen.dart';
import 'package:frontend/features/otp/screens/delivery_otp_screen.dart';

void main() {
  group('Responsive Layout Matrix Tests', () {
    testWidgets('Small Phone Portrait (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: TrackingScreen()),
      );

      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.byType(TrackingScreen), findsOneWidget);
    });

    testWidgets('Landscape Dual Pane (844x390)', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: TrackingScreen()),
      );

      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('LIVE METRICS'), findsOneWidget);
    });

    testWidgets('Tablet / Desktop Layout (1440x900)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: TrackingScreen()),
      );

      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('LIVE METRICS'), findsOneWidget);
    });

    testWidgets('Pickup OTP Responsive Layout (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: PickupOtpScreen()),
      );

      expect(find.text('Verify Pickup'), findsWidgets);
    });

    testWidgets('Delivery OTP Responsive Layout (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: DeliveryOtpScreen()),
      );

      expect(find.text('Verify Delivery'), findsWidgets);
    });
  });
}
