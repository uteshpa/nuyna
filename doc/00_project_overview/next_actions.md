# 次のアクション

**最終更新:** 2026年1月10日

---

## 1. Sprint 1: 基盤修正スプリント（2週間）

### P0（最優先）

| タスク | 内容 | 参照ドキュメント |
| :--- | :--- | :--- |
| **1. メタデータ削除問題の修正** | カスタムPlatform Channelを実装し、iOSでメタデータが削除されるようにする。 | [ios_implementation.md](../04_implementation/ios_implementation.md) |
| **2. クラウドテストの導入** | Firebase Test Labをセットアップし、iOS/Androidの基本動作確認を行う。 | [android_testing_strategy.md](../06_sprints/sprint_10_onwards/android_testing_strategy.md) |

### P1（高優先度）

| タスク | 内容 | 参照ドキュメント |
| :--- | :--- | :--- |
| **3. UI/UX改善** | 操作系をボタンのみに統一し、ワンタップ処理を実装する。 | [ui_improvement.md](../07_issues_and_fixes/ui_improvement.md) |
| **4. E2Eテストの導入** | ハッピーパス（動画選択→処理→保存）の自動テストを実装する。 | [qa_report.md](../05_quality_assurance/qa_report.md) |
| **5. パフォーマンス測定** | iPhone 11 Pro Maxで処理時間を実測し、ベンチマーク係数を適用して現行端末の性能を推定する。 | [test_environment_analysis.md](../09_reference/test_environment_analysis.md) |

### P2（中優先度）

| タスク | 内容 | 参照ドキュメント |
| :--- | :--- | :--- |
| **6. 未使用依存パッケージの削除** | 4つの未使用パッケージを `pubspec.yaml` から削除する。 | [dependency_analysis.md](../09_reference/dependency_analysis.md) |
| **7. Android実機の調達** | Google Pixel 6aなど、テスト用のAndroid実機を調達する。 | [test_environment_analysis.md](../09_reference/test_environment_analysis.md) |

---

## 2. Sprint 2: パフォーマンス改善スプリント（2週間）

- パフォーマンス改善（目標: 1分動画を60秒で処理）
- Android初期テスト（クラウドテスト + 実機）
- エラーハンドリングの強化

---

## 3. Sprint 3: リリース準備スプリント（3週間）

- iOS/Android版の品質向上
- ベータテストの実施
- ストア申請準備

---

## 4. 全体ロードマップ

詳細は [総合開発計画](../06_sprints/sprint_10_onwards/comprehensive_development_plan.md) を参照してください。
