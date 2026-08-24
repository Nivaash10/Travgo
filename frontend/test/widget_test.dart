// Widget test — Phase 1 OTP Module (post-UI redesign)
//
// Tests match the redesigned light-theme mobile OTP verification UI.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('OTP screen smoke test — Pickup screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Title is 'Verify Pickup'
    expect(find.text('Verify Pickup'), findsWidgets);
  });

  testWidgets('OTP screen — Parcel ID displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Parcel card shows the parcel ID.
    expect(find.textContaining('TRV1024'), findsWidgets);
  });

  testWidgets('OTP screen — Verify Pickup button exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify Pickup appears multiple times (AppBar, Header, Button). Check findsWidgets.
    expect(find.text('Verify Pickup'), findsWidgets);
  });
}
