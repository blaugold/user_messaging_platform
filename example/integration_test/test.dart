import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('request consent information update',
      (WidgetTester tester) async {
    final ump = UserMessagingPlatform.instance;

    var info = await ump.getConsentInfo();

    if (defaultTargetPlatform == TargetPlatform.android) {
      // On android formStatus is a bool, so `unknown` does not apply.
      expect(info.formStatus, equals(FormStatus.unavailable));
    } else {
      expect(info.formStatus, equals(FormStatus.unknown));
    }

    info = await ump.requestConsentInfoUpdate();

    expect(info.formStatus, equals(FormStatus.available));
  });

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    testWidgets(
      'get tracking authorization status',
      (WidgetTester tester) async {
        final status = await UserMessagingPlatform.instance
            .getTrackingAuthorizationStatus();

        expect(status, equals(TrackingAuthorizationStatus.notDetermined));
      },
    );
  }
}
