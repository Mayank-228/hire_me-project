import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hire_me/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HireMeApp()));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(HireMeApp), findsOneWidget);
  });
}
