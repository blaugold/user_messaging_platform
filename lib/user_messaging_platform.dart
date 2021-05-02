import 'package:collection/collection.dart'
    show IterableExtension, DeepCollectionEquality;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Debug values for testing geography.
enum DebugGeography {
  /// Disable geography debugging.
  disabled,

  /// Geography appears as in EEA for debug devices.
  EEA,

  /// Geography appears as not in EEA for debug devices.
  notEEA,
}

/// Settings for debugging or testing.
@immutable
class ConsentDebugSettings {
  /// Creates settings for debugging or testing.
  ConsentDebugSettings({
    this.testDeviceIds,
    this.geography = DebugGeography.disabled,
  });

  /// Array of device identifier strings. Debug features are enabled for devices
  /// with these identifiers. Debug features are always enabled for simulators.
  final List<String>? testDeviceIds;

  /// Debug geography.
  final DebugGeography geography;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentDebugSettings &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality.unordered()
              .equals(testDeviceIds, other.testDeviceIds) &&
          geography == other.geography;

  @override
  int get hashCode =>
      const DeepCollectionEquality.unordered().hash(testDeviceIds) ^
      geography.hashCode;

  @override
  String toString() => 'ConsentDebugSettings('
      'testDeviceIds: $testDeviceIds, '
      'geography: $geography'
      ')';
}

/// Parameters sent on updates to user consent info.
@immutable
class ConsentRequestParameters {
  /// Creates parameters sent on updates to user consent info.
  ConsentRequestParameters({
    this.tagForUnderAgeOfConsent = false,
    this.debugSettings,
  });

  /// Indicates whether the user is tagged for under age of consent.
  final bool tagForUnderAgeOfConsent;

  /// Debug settings for the request.
  final ConsentDebugSettings? debugSettings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentRequestParameters &&
          runtimeType == other.runtimeType &&
          tagForUnderAgeOfConsent == other.tagForUnderAgeOfConsent &&
          debugSettings == other.debugSettings;

  @override
  int get hashCode => tagForUnderAgeOfConsent.hashCode ^ debugSettings.hashCode;

  @override
  String toString() => 'ConsentRequestParameters('
      'tagForUnderAgeOfConsent: $tagForUnderAgeOfConsent, '
      'debugSettings: $debugSettings'
      ')';
}

/// Consent status values.
enum ConsentStatus {
  /// Unknown consent status.
  unknown,

  /// User consent required but not yet obtained.
  required,

  /// Consent not required.
  notRequired,

  /// Consent has been obtained.
  obtained,
}

/// Type of user consent.
enum ConsentType {
  /// User consent either not obtained or personalized vs < non-personalized
  /// status undefined.
  unknown,

  /// User consented to personalized ads.
  personalized,

  /// User consented to non-personalized ads.
  nonPersonalized,
}

/// State values for whether the user has a consent form available to them.
/// To check whether form status has changed, an update can be requested through
/// [UserMessagingPlatform.requestConsentInfoUpdate].
enum FormStatus {
  /// Whether a consent form is available is unknown. An update should be
  /// requested using [UserMessagingPlatform.requestConsentInfoUpdate].
  unknown,

  /// Consent forms are available and can be shown to the user using
  /// [UserMessagingPlatform.showConsentForm].
  available,

  /// Consent forms are unavailable. Showing a consent form is not required.
  unavailable,
}

/// Consent information.
@immutable
class ConsentInformation {
  /// Const constructor for [ConsentInformation].
  const ConsentInformation({
    required this.consentStatus,
    required this.consentType,
    required this.formStatus,
  });

  /// The user’s consent status. This value is cached between app sessions and
  /// can be read before requesting updated parameters.
  final ConsentStatus consentStatus;

  /// The user’s consent type. This value is cached between app sessions and can
  /// be read before requesting updated parameters.
  final ConsentType consentType;

  /// Consent form status. This value defaults to UMPFormStatusUnknown and
  /// requires a call to [UserMessagingPlatform.requestConsentInfoUpdate] to
  /// update.
  final FormStatus formStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentInformation &&
          runtimeType == other.runtimeType &&
          consentStatus == other.consentStatus &&
          consentType == other.consentType &&
          formStatus == other.formStatus;

  @override
  int get hashCode =>
      consentStatus.hashCode ^ consentType.hashCode ^ formStatus.hashCode;

  @override
  String toString() => 'ConsentInformation('
      'consentStatus: $consentStatus, '
      'consentType: $consentType, '
      'formStatus: $formStatus'
      ')';
}

/// Base exception for exceptions thrown by [UserMessagingPlatform].
@immutable
abstract class UserMessagingPlatformException implements Exception {
  /// Constructor for subclasses.
  const UserMessagingPlatformException({
    required this.message,
    required this.code,
    required this.originalException,
  });

  /// A human readable message, describing the exception.
  final String message;

  /// An error code.
  final Object code;

  /// The original platform exception.
  final PlatformException originalException;

  String get _debugName;

  @override
  String toString() => '$_debugName(message: $message, code: $code)';
}

/// Error codes used when making requests to update consent info.
enum RequestErrorCode {
  /// Internal error.
  internal,

  /// The application’s app ID is invalid.
  invalidAppID,

  /// Network error communicating with Funding Choices.
  network,

  /// Some kind of misconfiguration.
  misconfiguration,

  /// Invalid operation. The SDK is being invoked incorrectly.
  invalidOperation,
}

/// Exception which is thrown from
/// [UserMessagingPlatform.requestConsentInfoUpdate], when the request could not
/// be completed.
class RequestException extends UserMessagingPlatformException {
  /// Const constructor for [RequestException].
  const RequestException({
    required String message,
    required RequestErrorCode code,
    required PlatformException originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );

  @override
  String get _debugName => 'RequestException';

  @override
  RequestErrorCode get code => super.code as RequestErrorCode;
}

/// Error codes used when loading and showing forms.
enum FormErrorCode {
  /// Internal error.
  internal,

  /// Form was already used.
  alreadyUsed,

  /// Form is unavailable.
  unavailable,

  /// Loading a form timed out.
  timeout,

  /// Invalid operation. The SDK is being invoked incorrectly.
  invalidOperation,
}

/// Exception which is thrown from
/// [UserMessagingPlatform.showConsentForm], when the form could not
/// be shown.
class FormException extends UserMessagingPlatformException {
  /// Const constructor for [FormException].
  const FormException({
    required String message,
    required FormErrorCode code,
    required PlatformException originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );

  @override
  String get _debugName => 'FormException';

  @override
  FormErrorCode get code => super.code as FormErrorCode;
}

/// The status values for app tracking authorization.
///
/// See:
/// - [Docs](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/authorizationstatus)
enum TrackingAuthorizationStatus {
  /// The value returned if the user authorizes access to app-related data that
  /// can be used for tracking the user or the device.
  authorized,

  /// The value returned if the user denies authorization to access app-related
  /// data that can be used for tracking the user or the device.
  denied,

  /// The value returned if a user has not yet received an authorization request
  /// to authorize access to app-related data that can be used for tracking the
  /// user or the device.
  notDetermined,

  /// The value returned if authorization to access app-related data that can be
  /// used for tracking the user or the device is restricted.
  restricted,
}

/// A plugin which provides a Dart API for the User Messaging Platform
/// (UMP) SDK, which is the Consent Management Platform (CMP) SDK provided as
/// part of Google's Funding Choices.
///
/// ## App Tracking Transparency Framework (iOS/macOS)
///
/// To use the App Tracking Transparency framework:
/// - Set up a [NSUserTrackingUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription)
/// - Link the app to the `AppTrackingTransparency` framework
///
/// See:
/// - [ATT Docs](https://developer.apple.com/documentation/apptrackingtransparency)
class UserMessagingPlatform {
  const UserMessagingPlatform._();

  static const _channel =
      MethodChannel('com.terwesten.gabriel/user_messaging_platform');

  static const _unknownErrorCode = 'unknown';

  /// The singleton instance of the [UserMessagingPlatform] plugin.
  static const instance = UserMessagingPlatform._();

  /// Returns the current [ConsentInformation] for the current user.
  ///
  /// To get the most up to date information use [requestConsentInfoUpdate].
  Future<ConsentInformation> getConsentInfo() => _channel
      .invokeMethod<Map>('getConsentInfo')
      .then((it) => it!.cast<String, String>())
      .then(_parseConsentInformation);

  /// Updates the [ConsentInformation] for the current user.
  ///
  /// Callers should handle [RequestException]s.
  Future<ConsentInformation> requestConsentInfoUpdate([
    ConsentRequestParameters? parameters,
  ]) async {
    try {
      return await _channel
          .invokeMethod<Map>('requestConsentInfoUpdate', parameters?.toJson())
          .then((it) => it!.cast<String, String>())
          .then(_parseConsentInformation);
    } on PlatformException catch (exception) {
      if (exception.code == _unknownErrorCode) {
        rethrow;
      }

      final code = _enumFromString(RequestErrorCode.values, exception.code);
      if (code == null) {
        rethrow;
      }

      throw RequestException(
        message: exception.message!,
        code: code,
        originalException: exception,
      );
    }
  }

  /// Shows the consent form to the user and returns the updated
  /// [ConsentInformation].
  ///
  /// Callers should handle [FormException]s.
  Future<ConsentInformation> showConsentForm() async {
    try {
      return await _channel
          .invokeMethod<Map>('showConsentForm')
          .then((it) => it!.cast<String, String>())
          .then(_parseConsentInformation);
    } on PlatformException catch (exception) {
      if (exception.code == _unknownErrorCode) {
        rethrow;
      }

      final code = _enumFromString(FormErrorCode.values, exception.code);
      if (code == null) {
        rethrow;
      }

      throw FormException(
        message: exception.message!,
        code: code,
        originalException: exception,
      );
    }
  }

  /// Resets the consent information.
  Future<void> resetConsentInfo() =>
      _channel.invokeMethod<void>('resetConsentInfo');

  /// Returns a [Future] which resolves to the authorization status that is
  /// current for the calling application.
  ///
  /// If the App Tracking Transparency Framework is not available on the device
  /// the [Future] resolves to `null`.
  ///
  /// Only available on iOS/macOS.
  ///
  /// See:
  /// - [ATT Docs](https://developer.apple.com/documentation/apptrackingtransparency)
  Future<TrackingAuthorizationStatus?> getTrackingAuthorizationStatus() =>
      _channel.invokeMethod<String>('getTrackingAuthorizationStatus').then(
          (result) => result == null
              ? null
              : _enumFromString(TrackingAuthorizationStatus.values, result));

  /// Request to authorize or deny access to app-related data that can be used
  /// for tracking the user or the device.
  ///
  /// Returns a [Future] which resolves to the authorization status that is
  /// current for the calling application.
  ///
  /// If the App Tracking Transparency Framework is not available on the device
  /// the [Future] resolves to `null`.
  ///
  /// Only available on iOS/macOS.
  ///
  /// See:
  /// - [ATT Docs](https://developer.apple.com/documentation/apptrackingtransparency)
  Future<TrackingAuthorizationStatus?> requestTrackingAuthorization() =>
      _channel.invokeMethod<String>('requestTrackingAuthorization').then(
          (result) => result == null
              ? null
              : _enumFromString(TrackingAuthorizationStatus.values, result));
}

ConsentInformation _parseConsentInformation(Map<String, String> info) =>
    ConsentInformation(
      consentStatus:
          _enumFromString(ConsentStatus.values, info['consentStatus']!)!,
      consentType: _enumFromString(ConsentType.values, info['consentType']!)!,
      formStatus: _enumFromString(FormStatus.values, info['formStatus']!)!,
    );

/// Returns one of the values of an enum, whose name matches a string.
T? _enumFromString<T extends Object>(List<T> enumValues, String valueName) =>
    enumValues.firstWhereOrNull((it) => describeEnum(it) == valueName);

String _enumToString(Object value) => value.toString().split('.')[1];

extension on ConsentDebugSettings {
  Map<String, dynamic> toJson() => <String, dynamic>{
        'testDeviceIds': testDeviceIds,
        'geography': _enumToString(geography),
      };
}

extension on ConsentRequestParameters {
  Map<String, dynamic> toJson() => <String, dynamic>{
        'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent,
        'debugSettings': debugSettings?.toJson(),
      };
}
