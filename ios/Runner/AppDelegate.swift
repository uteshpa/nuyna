import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup MediaPipe Platform Channel
    setupMediaPipeChannel()
    
    // Setup VideoSaver Platform Channel for metadata-free video saving
    setupVideoSaverChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupVideoSaverChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let videoSaverChannel = FlutterMethodChannel(
      name: "com.uteshpa.nuyna/video_saver",
      binaryMessenger: controller.binaryMessenger
    )
    
    videoSaverChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "saveVideoWithoutMetadata":
        self?.handleSaveVideoWithoutMetadata(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func handleSaveVideoWithoutMetadata(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let filePath = args["filePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "filePath is required", details: nil))
      return
    }
    
    VideoSaver.saveVideoWithoutMetadata(filePath: filePath) { success, error in
      if success {
        result(true)
      } else {
        result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription ?? "Unknown error", details: nil))
      }
    }
  }
  
  private func setupMediaPipeChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let mediaPipeChannel = FlutterMethodChannel(
      name: "com.nuyna.mediapipe/hands",
      binaryMessenger: controller.binaryMessenger
    )
    
    mediaPipeChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "detectHandLandmarks" {
        self?.handleDetectHandLandmarks(call: call, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  /// Handle detectHandLandmarks method call
  /// Returns dummy landmark data for testing purposes
  private func handleDetectHandLandmarks(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // In production, this would integrate with the actual MediaPipe SDK
    // For now, return dummy landmarks for testing the Platform Channel integration
    
    // 21 hand landmarks with dummy normalized coordinates (0.0-1.0)
    let dummyLandmarks: [[Double]] = [
      [0.5, 0.8],    // 0: WRIST
      [0.45, 0.75],  // 1: THUMB_CMC
      [0.40, 0.70],  // 2: THUMB_MCP
      [0.35, 0.65],  // 3: THUMB_IP
      [0.30, 0.60],  // 4: THUMB_TIP
      [0.45, 0.55],  // 5: INDEX_FINGER_MCP
      [0.45, 0.45],  // 6: INDEX_FINGER_PIP
      [0.45, 0.35],  // 7: INDEX_FINGER_DIP
      [0.45, 0.25],  // 8: INDEX_FINGER_TIP
      [0.50, 0.55],  // 9: MIDDLE_FINGER_MCP
      [0.50, 0.43],  // 10: MIDDLE_FINGER_PIP
      [0.50, 0.33],  // 11: MIDDLE_FINGER_DIP
      [0.50, 0.23],  // 12: MIDDLE_FINGER_TIP
      [0.55, 0.57],  // 13: RING_FINGER_MCP
      [0.55, 0.47],  // 14: RING_FINGER_PIP
      [0.55, 0.37],  // 15: RING_FINGER_DIP
      [0.55, 0.27],  // 16: RING_FINGER_TIP
      [0.60, 0.60],  // 17: PINKY_MCP
      [0.60, 0.52],  // 18: PINKY_PIP
      [0.60, 0.44],  // 19: PINKY_DIP
      [0.60, 0.36],  // 20: PINKY_TIP
    ]
    
    // Return as array of hand results (single hand for demo)
    let handResult: [String: Any] = [
      "landmarks": dummyLandmarks,
      "handSize": 0.15,
      "confidence": 0.95
    ]
    
    // Return array of hands (could be multiple)
    result([handResult])
  }
}
