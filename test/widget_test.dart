import 'package:flutter_test/flutter_test.dart';
import 'package:time_calculator/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TimeCalculatorApp());
    expect(find.text('Time Calculator'), findsOneWidget);
  });
}
