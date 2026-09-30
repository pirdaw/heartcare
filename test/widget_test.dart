import 'package:flutter_test/flutter_test.dart';
import 'package:heartcare/main.dart';

void main() {
  testWidgets('HeartCare app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HeartCareApp());

    // Verify that the welcome page renders
    expect(find.byType(HeartCareApp), findsOneWidget);
  });
}
