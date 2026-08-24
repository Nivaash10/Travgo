import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Sender dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Sender Dashboard renders title and header text.
    expect(find.text('TRAVGO'), findsOneWidget);
    expect(find.text('Hello, Sender'), findsOneWidget);
    expect(find.text('Where do you want to send a parcel?'), findsOneWidget);
  });
}
