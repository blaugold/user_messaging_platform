import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_messaging_platform_example/main.dart' as app;

void main() => run(_testMain);

void _testMain() {
  testWidgets('smoke test', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
  });
}
