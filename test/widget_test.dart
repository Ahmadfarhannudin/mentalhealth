import 'package:flutter_test/flutter_test.dart';
import 'package:mentalhealth/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TenangApp());
    expect(find.byType(TenangApp), findsOneWidget);
  });
}
