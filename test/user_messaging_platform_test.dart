import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPlatformConsentInfo = {
    'consentStatus': 'obtained',
    'consentType': 'personalized',
    'formStatus': 'available',
  };

  final testConsentInfo = ConsentInformation(
    consentStatus: ConsentStatus.obtained,
    consentType: ConsentType.personalized,
    formStatus: FormStatus.available,
  );

  const channel =
      MethodChannel('com.terwesten.gabriel/user_messaging_platform');

  final methodCallResult = <String, Object>{};
  final methodCallException = <String, PlatformException>{};

  final ump = UserMessagingPlatform.instance;

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCallResult.containsKey(methodCall.method)) {
        return methodCallResult[methodCall.method];
      }

      if (methodCallException.containsKey(methodCall.method)) {
        throw methodCallException[methodCall.method];
      }

      throw UnimplementedError();
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    methodCallResult.clear();
    methodCallException.clear();
  });

  test('getConsentInfo', () async {
    methodCallResult['getConsentInfo'] = testPlatformConsentInfo;

    final info = await ump.getConsentInfo();

    expect(info, equals(testConsentInfo));
  });

  test('requestConsentInfoUpdate success', () async {
    methodCallResult['requestConsentInfoUpdate'] = testPlatformConsentInfo;

    final info = await ump.requestConsentInfoUpdate();

    expect(info, equals(testConsentInfo));
  });

  test('requestConsentInfoUpdate exception', () async {
    methodCallException['requestConsentInfoUpdate'] = PlatformException(
      message: 'Test',
      code: 'internal',
    );

    RequestException ex;
    try {
      await ump.requestConsentInfoUpdate();
    } on RequestException catch (_ex) {
      ex = _ex;
    }

    expect(ex.message, equals('Test'));
    expect(ex.code, equals(RequestErrorCode.internal));
  });

  test('showConsentForm success', () async {
    methodCallResult['showConsentForm'] = testPlatformConsentInfo;

    final info = await ump.showConsentForm();

    expect(info, equals(testConsentInfo));
  });

  test('showConsentForm exception', () async {
    methodCallException['showConsentForm'] = PlatformException(
      message: 'Test',
      code: 'internal',
    );

    FormException ex;
    try {
      await ump.showConsentForm();
    } on FormException catch (_ex) {
      ex = _ex;
    }

    expect(ex.message, equals('Test'));
    expect(ex.code, equals(FormErrorCode.internal));
  });

  test('resetConsentInfo', () async {
    methodCallResult['resetConsentInfo'] = null;

    await ump.resetConsentInfo();
  });

  test('getTrackingAuthorizationStatus when available', () async {
    methodCallResult['getTrackingAuthorizationStatus'] = 'authorized';

    final status = await ump.getTrackingAuthorizationStatus();

    expect(status, equals(TrackingAuthorizationStatus.authorized));
  });

  test('getTrackingAuthorizationStatus when unavailable', () async {
    methodCallResult['getTrackingAuthorizationStatus'] = null;

    final status = await ump.getTrackingAuthorizationStatus();

    expect(status, isNull);
  });

  test('requestTrackingAuthorization when available', () async {
    methodCallResult['requestTrackingAuthorization'] = 'authorized';

    final status = await ump.requestTrackingAuthorization();

    expect(status, equals(TrackingAuthorizationStatus.authorized));
  });

  test('requestTrackingAuthorization when unavailable', () async {
    methodCallResult['requestTrackingAuthorization'] = null;

    final status = await ump.requestTrackingAuthorization();

    expect(status, isNull);
  });
}
