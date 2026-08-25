import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('OTP screen smoke test — Pickup screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TravgoApp());
    await tester.pump();

    expect(find.text('Verify Pickup'), findsWidgets);
  });

  testWidgets('OTP screen — Parcel ID displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TravgoApp());
    await tester.pump();

    expect(find.textContaining('TRV1024'), findsWidgets);
  });

  testWidgets('OTP screen — Verify Pickup button exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TravgoApp());
    await tester.pump();

    expect(find.text('Verify Pickup'), findsWidgets);
  });
}