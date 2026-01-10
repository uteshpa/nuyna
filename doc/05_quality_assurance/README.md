# 品質保証ドキュメント

このディレクトリには、nuynaの品質保証に関するドキュメントが格納されています。

---

## 📋 ドキュメント一覧

| ファイル | 内容 | 最終更新 |
| :--- | :--- | :--- |
| **[qa_report.md](qa_report.md)** | 総合品質評価レポート（スコア58/100） | 2026-01-10 |
| **[code_review_findings.md](code_review_findings.md)** | コードベース全体のレビュー結果 | 2026-01-10 |
| **test_scenarios/** | テストシナリオ集 | - |

---

## 🎯 重要な発見事項

### 総合品質スコア: 58 / 100 (F - リリース不可)

**致命的な問題（P0）:**
- iOSでメタデータが削除されない

**高優先度の問題（P1）:**
- UI操作系の混乱（ボタンとスイッチの混在）
- パフォーマンス目標未達
- 統合・E2Eテストの欠如

詳細は [qa_report.md](qa_report.md) を参照してください。

---

## 📂 test_scenarios/

| ファイル | 内容 |
| :--- | :--- |
| **[sprint9_verification.md](test_scenarios/sprint9_verification.md)** | Sprint 9完了検証シナリオ |
| **[sprint9_performance.md](test_scenarios/sprint9_performance.md)** | Sprint 9パフォーマンス測定シナリオ |
| **[sprint10_test_scenarios.md](test_scenarios/sprint10_test_scenarios.md)** | Sprint 10テストシナリオ |
