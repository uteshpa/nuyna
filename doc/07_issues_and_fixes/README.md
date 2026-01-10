# 問題と修正記録

このディレクトリには、nuynaで発見された問題と、その修正方法が記録されています。

---

## 📋 ドキュメント一覧

| ファイル | 優先度 | 内容 | ステータス |
| :--- | :--- | :--- | :--- |
| **[metadata_deletion_issue.md](metadata_deletion_issue.md)** | **P0** | iOSでメタデータが削除されない問題 | 🔴 修正中 |
| **[ui_improvement.md](ui_improvement.md)** | **P1** | UI/UX改善（操作系統一、ワンタップ処理） | 🔴 修正中 |

---

## 🔴 P0問題: メタデータ削除機能不全

**問題:** iOSのフォトライブラリに保存する際、`PHPhotoLibrary` APIが自動的にメタデータを再付与している。

**影響:** プライバシー保護というコアバリューを根底から覆す致命的欠陥。

**修正方法:** カスタムPlatform Channelを実装し、`PHAssetCreationRequest`のオプションを制御する。

詳細は [metadata_deletion_issue.md](metadata_deletion_issue.md) を参照してください。

---

## 🟡 P1問題: UI操作系の混乱

**問題:** 同じ機能に対して、ボタンとスイッチの2つの操作系が混在している。

**影響:** ユーザーを混乱させ、体験を著しく損なう。

**修正方法:** 操作系をボタンのみに統一し、ワンタップ処理を実装する。

詳細は [ui_improvement.md](ui_improvement.md) を参照してください。
