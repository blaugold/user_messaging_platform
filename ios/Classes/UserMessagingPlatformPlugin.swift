import Flutter
import UIKit
import UserMessagingPlatform
import AppTrackingTransparency

private let unknownErrorCode = "unknown"

public class UserMessagingPlatformPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.terwesten.gabriel/user_messaging_platform",
            binaryMessenger: registrar.messenger()
        )
        let instance = UserMessagingPlatformPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var viewController: UIViewController {
        get {
            UIApplication.shared.windows.first!.rootViewController!
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "getConsentInfo":
            result(self.getConsentInfo())
            break
        case "requestConsentInfoUpdate":
            self.requestConsentInfoUpdate(result)
            break
        case "showConsentForm":
            self.showConsentForm(result)
            break
        case "resetConsentInfo":
            self.resetConsentInfo(result)
            break
        case "getTrackingAuthorizationStatus":
            self.getTrackingAuthorizationStatus(result)
            break;
        case "requestTrackingAuthorization":
            self.requestTrackingAuthorization(result)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getConsentInfo() -> [String: String] {
        return self.serializeConsentInfo(UMPConsentInformation.sharedInstance)
    }
    
    private func serializeConsentInfo(_ info: UMPConsentInformation) -> [String: String] {
        return [
            "consentStatus": "\(info.consentStatus)",
            "consentType": "\(info.consentType)",
            "formStatus": "\(info.formStatus)",
        ]
    }
    
    private func requestConsentInfoUpdate(_ result: @escaping FlutterResult) {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { error in
            if let error = error as NSError? {
                if error.domain == UMPErrorDomain {
                    let code = UMPRequestErrorCode(rawValue: error.code)!
                    result(FlutterError(
                        code: "\(code)",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(FlutterError(
                        code: unknownErrorCode,
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            } else {
                result(self.getConsentInfo())
            }
        }
    }
    
    private func showConsentForm(_ result: @escaping FlutterResult) {
        UMPConsentForm.load { [self] form, error in
            if let error = error as NSError? {
                if error.domain == UMPErrorDomain {
                    let code = UMPFormErrorCode(rawValue: error.code)!
                    result(FlutterError(
                        code: "\(code)",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(FlutterError(
                        code: unknownErrorCode,
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            } else {
                form!.present(from: self.viewController) { error in
                    if let error = error as NSError? {
                        if error.domain == UMPErrorDomain {
                            let code = UMPFormErrorCode(rawValue: error.code)!
                            result(FlutterError(
                                code: "\(code)",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        } else {
                            result(FlutterError(
                                code: unknownErrorCode,
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    } else {
                        result(getConsentInfo())
                    }
                }
            }
        }
    }
    
    private func resetConsentInfo(_ result: @escaping FlutterResult) {
        UMPConsentInformation.sharedInstance.reset()
        result(nil)
    }
    
    private func getTrackingAuthorizationStatus(_ result: @escaping FlutterResult) {
        if #available(iOS 14, *) {
            result(ATTrackingManager.trackingAuthorizationStatus.description)
        } else {
            result(nil)
        }
    }
    
    private func requestTrackingAuthorization(_ result: @escaping FlutterResult) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                result(status.description)
            }
        } else {
            result(nil)
        }
    }
}

extension UMPConsentStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown";
        case .notRequired:
            return "notRequired";
        case .required:
            return "required";
        case .obtained:
            return "obtained";
        @unknown default:
            fatalError()
        }
    }
}

extension UMPConsentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown";
        case .personalized:
            return "personalized";
        case .nonPersonalized:
            return "nonPersonalized";
        @unknown default:
            fatalError()
        }
    }
}

extension UMPFormStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown";
        case .available:
            return "available";
        case .unavailable:
            return "unavailable";
        @unknown default:
            fatalError()
        }
    }
}

extension UMPRequestErrorCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .internal:
            return "internal";
        case .invalidAppID:
            return "invalidAppID";
        case .misconfiguration:
            return "misconfiguration";
        case .network:
            return "network";
        @unknown default:
            fatalError()
        }
    }
}

extension UMPFormErrorCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .internal:
            return "internal";
        case .alreadyUsed:
            return "alreadyUsed";
        case .timeout:
            return "timeout";
        case .unavailable:
            return "unavailable";
        @unknown default:
            fatalError()
        }
    }
}

@available(iOS 14, *)
extension ATTrackingManager.AuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authorized:
            return "authorized";
        case .denied:
            return "denied";
        case .notDetermined:
            return "notDetermined";
        case .restricted:
            return "restricted";
        @unknown default:
            fatalError()
        }
    }
}
