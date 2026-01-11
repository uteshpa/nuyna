# P0_iOS_Metadata_Fix_Report

**Date:** 2026-01-11  
**Priority:** P0 (Critical)  
**Status:** 🔴 Investigation Required

## Overview

iOSでのメタデータ削除が正しく機能していない問題の調査・修正レポート。

---

## Issue Summary

| 項目 | 詳細 |
| ------ | ------ |
| Issue ID | P0-iOS-METADATA-001 |
| 報告日 | 2026-01-11 |
| 対象OS | iOS |
| 影響度 | Critical - プライバシー保護機能の根幹に関わる |
| 現象 | 処理後の動画にGPS位置情報、撮影日時、デバイス情報が残存 |

---

## Root Cause Analysis

### 問題の原因

`GallerySaver.saveVideo()` 使用時に、iOSの `PHPhotoLibrary` APIが自動的にメタデータを付与してしまう。

### 技術的詳細

1. **FFmpegでの処理**: `-map_metadata -1` オプションでメタデータ削除 ✅
2. **一時ファイル**: メタデータなし ✅
3. **フォトライブラリ保存**: `PHAssetChangeRequest` がメタデータを再付与 ❌

---

## Investigation Log

### Step 1: FFmpeg処理確認

**Status:** ✅ 問題なし

```text
確認コマンド: -map_metadata -1 -movflags +faststart
結果: 一時ファイルにメタデータは含まれていない
```

### Step 2: GallerySaver動作確認

**Status:** ❌ 問題あり

```text
gallery_saver_plus使用時にPHPhotoLibraryがメタデータを自動付与
- creationDate: 保存時刻
- location: デバイス現在地
- deviceModel: 使用デバイス情報
```

### Step 3: 解決策検討

| 方法 | 説明 | 採用 |
| ------ | ------ | ------ |
| Method 1 | カスタムPlatform Channelでメタデータ制御 | 🎯 推奨 |
| Method 2 | 保存後にPHAssetでメタデータ削除 | ❌ 制限あり |
| Method 3 | Files.app経由で共有 | ❌ UX低下 |

---

## Fix Implementation Plan

### Phase 1: Platform Channel実装

```text
1. lib/data/datasources/native_gallery_datasource.dart 作成
2. ios/Runner/GalleryChannel.swift 作成
3. メタデータなし保存ロジック実装
```

### Phase 2: 既存コード置換

```text
1. result_page.dart の _saveToGallery() を更新
2. GallerySaver.saveVideo() → NativeGalleryDatasource.saveWithoutMetadata()
```

### Phase 3: 検証

```text
1. 保存後の動画をexiftoolで確認
2. iOSフォトアプリで位置情報・日時を確認
3. 回帰テスト実行
```

---

## Action Items

- [ ] Platform Channel設計
- [ ] Swift側実装（GalleryChannel.swift）
- [ ] Dart側実装（NativeGalleryDatasource）
- [ ] ResultPageの更新
- [ ] iOS実機テスト
- [ ] ドキュメント更新

---

## Related Files

- `lib/features/result/view/result_page.dart` - 保存処理
- `lib/domain/usecases/process_media_usecase.dart` - メタデータ削除処理
- `doc/07_issues_and_fixes/metadata_deletion_issue.md` - 詳細分析

---

## Timeline

| Date | Action | Status |
| ------ | -------- | -------- |
| 2026-01-11 | Issue報告・調査開始 | 🟡 In Progress |
| TBD | Platform Channel実装 | ⬜ Pending |
| TBD | iOS実機テスト | ⬜ Pending |
| TBD | Fix完了・リリース | ⬜ Pending |

---

## Notes

本issueはプロダクトのコア価値である「プライバシー保護」に直接影響するため、P0優先度として対応する。

---

*Last Updated: 2026-01-11 15:11 JST*
