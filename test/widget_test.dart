import 'package:flutter_test/flutter_test.dart';

import 'package:unworn/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UnwornApp());
    await tester.pumpAndSettle();

    expect(find.text('UNWORN'), findsOneWidget);
  });
}
