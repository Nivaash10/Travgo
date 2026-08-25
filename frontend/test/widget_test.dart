import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Travgo app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TravgoApp());
    await tester.pumpAndSettle();

    expect(find.byType(TravgoApp), findsOneWidget);
  });
}
