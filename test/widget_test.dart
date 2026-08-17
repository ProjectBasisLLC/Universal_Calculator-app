import 'package:flutter_test/flutter_test.dart';
import 'package:r4t_io_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const R4TIoApp());
    expect(find.text('Time'), findsOneWidget);
  });
}
