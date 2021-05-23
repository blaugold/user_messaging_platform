import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPlatformConsentInfo = {
    'consentStatus': 'obtained',
    'formStatus': 'available',
  };

  final testConsentInfo = ConsentInformation(
    consentStatus: ConsentStatus.obtained,
    formStatus: FormStatus.available,
  );

  const channel =
      MethodChannel('com.terwesten.gabriel/user_messaging_platform');

  final methodCallArguments = <String, List<Object?>>{};
  final methodCallResult = <String, Object?>{};
  final methodCallException = <String, PlatformException>{};

  final ump = UserMessagingPlatform.instance;

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      methodCallArguments
          .putIfAbsent(methodCall.method, () => [])
          .add(methodCall.arguments);

      if (methodCallResult.containsKey(methodCall.method)) {
        return methodCallResult[methodCall.method];
      }

      if (methodCallException.containsKey(methodCall.method)) {
        throw methodCallException[methodCall.method]!;
      }

      throw UnimplementedError();
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    methodCallArguments.clear();
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

    expect(
      ump.requestConsentInfoUpdate(),
      throwsA(
        isA<RequestException>()
            .having((it) => it.message, 'message', equals('Test'))
            .having((it) => it.code, 'code', equals(RequestErrorCode.internal)),
      ),
    );
  });

  test('requestConsentInfoUpdate parameters', () async {
    methodCallResult['requestConsentInfoUpdate'] = testPlatformConsentInfo;

    final parameters = ConsentRequestParameters(
      tagForUnderAgeOfConsent: true,
      debugSettings: ConsentDebugSettings(
        geography: DebugGeography.EEA,
        testDeviceIds: ['a'],
      ),
    );
    final parametersJson = {
      'tagForUnderAgeOfConsent': true,
      'debugSettings': {
        'geography': 'EEA',
        'testDeviceIds': ['a'],
      },
    };

    await ump.requestConsentInfoUpdate(parameters);

    expect(
      methodCallArguments['requestConsentInfoUpdate']!.first,
      equals(parametersJson),
    );
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

    late FormException ex;
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
