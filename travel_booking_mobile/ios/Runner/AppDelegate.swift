import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // GMSServices.provideAPIKey() は Dart 側から --dart-define で渡されたキーで
    // MethodChannel 経由で初期化する。
    // runApp() 前に main.dart から invokeMethod('initialize') が呼ばれる。
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return result
    }
    let channel = FlutterMethodChannel(
      name: "travel_booking/google_maps",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "initialize",
            let args = call.arguments as? [String: Any],
            let apiKey = args["apiKey"] as? String,
            !apiKey.isEmpty
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      GMSServices.provideAPIKey(apiKey)
      result(nil)
    }

    return result
  }
}
