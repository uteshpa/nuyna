# iOS実装ガイド

**最終更新:** 2026年1月10日

---

## 1. メタデータ削除問題の修正

### 1.1. 概要

**問題:** iOSの `PHPhotoLibrary` APIが、フォトライブラリに保存する際に自動的にメタデータを再付与する。

**解決策:** カスタムPlatform Channelを実装し、`PHAssetCreationRequest`のオプションを制御して、メタデータを含めずに動画を保存する。

### 1.2. 実装ファイル

| ファイル | 役割 | 状態 |
| :--- | :--- | :--- |
| `ios/Runner/VideoSaver.swift` | メタデータなしで動画を保存するネイティブコード | 新規作成 |
| `ios/Runner/AppDelegate.swift` | Platform Channelを登録する | 修正 |
| `lib/data/datasources/video_saver_datasource.dart` | Flutter側からネイティブコードを呼び出す | 新規作成 |
| `lib/presentation/pages/result_page.dart` | 修正版のデータソースを呼び出す | 修正 |

### 1.3. コード詳細

#### VideoSaver.swift

```swift
import Photos

class VideoSaver {
    static func saveVideoWithoutMetadata(filePath: String, completion: @escaping (Bool, Error?) -> Void) {
        let videoURL = URL(fileURLWithPath: filePath)

        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = false // メタデータ自動付与を抑制
            creationRequest.addResource(with: .video, fileURL: videoURL, options: options)
        }) { (success, error) in
            completion(success, error)
        }
    }
}
```

#### AppDelegate.swift

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let videoChannel = FlutterMethodChannel(name: "com.uteshpa.nuyna/video_saver",
                                              binaryMessenger: controller.binaryMessenger)

    videoChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "saveVideoWithoutMetadata" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path is required", details: nil))
          return
      }

      VideoSaver.saveVideoWithoutMetadata(filePath: filePath) { (success, error) in
          if success {
              result(true)
          } else {
              result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription, details: nil))
          }
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### video_saver_datasource.dart

```dart
import 'package:flutter/services.dart';

class VideoSaverDataSource {
  static const _channel = MethodChannel('com.uteshpa.nuyna/video_saver');

  Future<bool> saveVideoWithoutMetadata(String filePath) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'saveVideoWithoutMetadata',
        {'filePath': filePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      // Handle error
      print("Failed to save video: '${e.message}'.");
      return false;
    }
  }
}
```

---

## 2. ビルド設定

### 2.1. Xcode

1. Xcodeで `ios/Runner.xcworkspace` を開く。
2. `VideoSaver.swift` を `Runner` グループに追加する。
3. `Info.plist` に `NSPhotoLibraryUsageDescription` が設定されていることを確認する。

### 2.2. CocoaPods

`pod install` を実行して、依存関係を更新する。

---

## 3. テスト

- **テストシナリオ:** `doc/05_quality_assurance/test_scenarios/sprint9_verification.md`
- **確認項目:** TC-META-01, TC-META-02
- **方法:**
  1. GPS権限を許可した状態でアプリを実行。
  2. 動画を処理し、保存。
  3. iOSの「写真」アプリで動画の詳細情報を確認し、位置情報が削除されていることを確認。
