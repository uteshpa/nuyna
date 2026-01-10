# メタデータ削除問題 - 完全分析レポート

## 🔍 問題の全容

**症状:** iOSのアルバムアプリで処理後の動画を確認すると、GPS位置情報、撮影日時、デバイス情報が削除されていない。

## 📊 処理フローの完全追跡

### 1. 動画処理フロー（process_media_usecase.dart）

```
ユーザーが動画選択
    ↓
HomeViewModel.processVideo()
    ↓
ProcessMediaUseCase.execute()
    ↓
_processVideo() - フレーム処理
    ↓
FFmpegでフレーム再組み立て + メタデータ削除
    ↓
一時ディレクトリに保存 (/var/.../nuyna_processed_xxx.mp4)
    ↓
ProcessedVideoオブジェクトを返す
    ↓
ResultPageに遷移
    ↓
ユーザーが「Save to Gallery」ボタンをタップ
    ↓
GallerySaver.saveVideo() ← ★ここで問題発生
    ↓
iOSフォトライブラリに保存
```

### 2. メタデータ削除の実装箇所

#### ✅ 正しく実装されている箇所

**process_media_usecase.dart (Line 389-392):**
```dart
final assembleCommand = '-framerate 10 -i "$processedFramesDir/frame_%04d.jpg" '
    '-i "$videoPath" -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p '
    '-map 0:v -map 1:a? -shortest '
    '-map_metadata -1 -movflags +faststart "$outputPath"';
```

**process_media_usecase.dart (Line 437):**
```dart
final command = '-i "$videoPath" -map_metadata -1 -c copy -movflags +faststart "$outputPath"';
```

FFmpegの `-map_metadata -1` オプションが正しく設定されており、**一時ファイルにはメタデータが含まれていない**。

### 3. ❌ 問題の根本原因

**result_page.dart (Line 71-114) の `_saveToGallery()` メソッド:**

```dart
Future<void> _saveToGallery() async {
  // ...
  result = await GallerySaver.saveVideo(widget.processedVideo.outputPath);
  // ...
}
```

`GallerySaver.saveVideo()` は内部で `PHPhotoLibrary` APIを使用しており、**iOSのフォトライブラリに保存する際に、以下のメタデータが自動的に付与される**：

1. **Creation Date（作成日時）**: 保存時の現在時刻
2. **Location（位置情報）**: デバイスの現在地（位置情報権限がある場合）
3. **Device Model（デバイス情報）**: 使用中のiPhoneモデル

これは、`gallery_saver_plus` パッケージの仕様であり、iOSの `PHPhotoLibrary` APIの標準動作です。

## 🔬 技術的詳細

### iOSのPHPhotoLibrary APIの動作

`gallery_saver_plus` は内部で以下のようなコードを使用していると推測されます：

```swift
PHPhotoLibrary.shared().performChanges({
    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
}, completionHandler: { success, error in
    // ...
})
```

この `creationRequestForAssetFromVideo` メソッドは、**自動的に以下のメタデータを付与**します：

- `creationDate`: 現在時刻
- `location`: CLLocationManager から取得した現在地
- `pixelWidth`, `pixelHeight`: 動画の解像度
- その他のシステムメタデータ

### なぜAndroidでは問題が発生しないか

Androidの `MediaStore` APIは、iOSの `PHPhotoLibrary` ほど積極的にメタデータを付与しません。`gallery_saver_plus` がAndroidで使用する `MediaStore.Video.Media` は、ファイルのメタデータをそのまま保持する傾向があります。

## 💡 解決策

### 方法1: カスタムiOSネイティブコードの実装（推奨）

`gallery_saver_plus` を使用せず、独自のPlatform Channelを実装してメタデータを制御します。

**実装手順:**

1. **Flutterのメソッドチャネルを作成**
2. **iOSのネイティブコードでメタデータなし保存を実装**
3. **既存の `_saveToGallery()` を置き換え**

### 方法2: 保存後に再度メタデータを削除（非推奨）

フォトライブラリに保存した後、`PHAsset` を取得してメタデータを削除する方法。ただし、iOSの仕様上、完全な削除は困難です。

### 方法3: ファイル共有で保存（UX変更）

フォトライブラリではなく、Files appやAirDropで共有し、ユーザーが手動で保存する方法。メタデータは削除されますが、ユーザー体験が低下します。

## 🎯 推奨アクション

**方法1（カスタムネイティブコード）を実装することを強く推奨します。**

理由：
- プロダクトのコア価値である「プライバシー保護」を完全に実現できる
- ユーザー体験を損なわない
- 技術的に実現可能で、実装も比較的シンプル

次のフェーズで、具体的な実装コードを提供します。
