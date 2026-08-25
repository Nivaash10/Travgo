import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Sender dashboard smoke test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const TravgoApp());
    await tester.pumpAndSettle();

    expect(find.text('TRAVGO'), findsOneWidget);
    expect(find.text('Hello, Sender'), findsOneWidget);
    expect(
      find.text('Where do you want to send a parcel?'),
      findsWidgets,
    );
  });
}
