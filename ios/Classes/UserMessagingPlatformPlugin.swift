import Flutter
import UIKit

public class UserMessagingPlatformPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.terwesten.gabriel/user_messaging_platform",
            binaryMessenger: registrar.messenger()
        )
        let instance = UserMessagingPlatformPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        fatalError()
    }
}
