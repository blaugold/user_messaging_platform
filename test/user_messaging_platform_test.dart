import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel =
      MethodChannel('com.terwesten.gabriel/user_messaging_platform');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      throw UnimplementedError();
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('smoke test', () async {});
}
