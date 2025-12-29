# nuyna iOS ビルド環境設定マニュアル

> **対象環境**: macOS 26.2 / Apple M1 / Xcode 26.2 / Flutter 3.35.7  
> **作成日**: 2025-12-30

---

## 前提条件

| 項目 | 必須バージョン |
|------|---------------|
| macOS | 26.2+ |
| Xcode | 26.2+ |
| Flutter | 3.35.7 |
| Dart | 3.9.2 |
| Ruby | 3.3.0 |
| CocoaPods | 1.16.2 |
| iOS Deployment Target | 15.5 |

---

## 1. 環境確認コマンド

```zsh
flutter doctor -v
xcode-select -p
pod --version
ruby --version
```

---

## 2. 初回セットアップ

### 2.1 リポジトリクローン

```zsh
git clone git@github.com:uteshpa/nuyna.git
cd nuyna
```

### 2.2 Flutter依存関係取得

```zsh
flutter pub get
```

### 2.3 iOS Pod インストール

```zsh
cd ios
pod install --repo-update
cd ..
```

---

## 3. iOSシミュレーター起動

### 3.1 利用可能なシミュレーター確認

```zsh
xcrun simctl list devices available
```

### 3.2 iPhone 16e シミュレーター起動

```zsh
xcrun simctl boot "iPhone 16e"
open -a Simulator
```

### 3.3 起動中シミュレーター確認

```zsh
xcrun simctl list devices booted
```

---

## 4. ビルド & 実行

### 4.1 デバッグビルド（シミュレーター）

```zsh
flutter run -d "iPhone 16e"
```

### 4.2 デバイス指定でビルド

```zsh
flutter devices
flutter run -d C13A6311-6747-4E12-8D9A-41B631491855
```

### 4.3 リリースビルド

```zsh
flutter build ios --release
```

---

## 5. クリーンビルド

### 5.1 Flutter クリーン

```zsh
flutter clean
flutter pub get
```

### 5.2 iOS Pod クリーン

```zsh
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### 5.3 完全クリーン

```zsh
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
flutter pub get
cd ios && pod install --repo-update && cd ..
```

---

## 6. テスト実行

### 6.1 ユニットテスト

```zsh
flutter test
```

### 6.2 静的解析

```zsh
flutter analyze
```

---

## 7. トラブルシューティング

### 7.1 Pod インストールエラー

```zsh
cd ios
pod cache clean --all
pod deintegrate
pod setup
pod install --repo-update
cd ..
```

### 7.2 Xcode ビルドエラー

```zsh
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter pub get
cd ios && pod install && cd ..
```

### 7.3 シミュレーターリセット

```zsh
xcrun simctl shutdown all
xcrun simctl erase all
```

### 7.4 Flutter キャッシュクリア

```zsh
flutter pub cache clean
flutter pub get
```

---

## 8. 環境変数設定（.zshrc）

```zsh
export PATH="$PATH:/opt/homebrew/share/flutter/bin"
export GRADLE_HOME=/opt/gradle/gradle-9.2.1
export PATH=$GRADLE_HOME/bin:$PATH
eval "$(rbenv init - zsh)"
```

---

## 9. クイックスタート

```zsh
cd /Users/uenoryouhei/Uteshpa/nuyna
flutter pub get
cd ios && pod install && cd ..
xcrun simctl boot "iPhone 16e"
flutter run
```

---

## 10. 現在の開発環境サマリー

| 項目 | 値 |
|------|-----|
| Flutter | 3.35.7 (stable) |
| Dart | 3.9.2 |
| Xcode | 26.2 (Build 17C52) |
| CocoaPods | 1.16.2 |
| Ruby | 3.3.0 (rbenv) |
| iOS SDK | 26.2 |
| Simulator | iPhone 16e (iOS 26.2) |
| Architecture | arm64 |
