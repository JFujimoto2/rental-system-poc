# ドキュメント一覧

## 01_investigation / 現行システム調査結果

| ファイル | 内容 |
|---------|------|
| system_investigation_checklist.md | Java 6 システム調査・判断タスク一覧 |
| additional_investigation.md | 追加調査項目チェックリスト（データ量・バッチ・外部連携） |
| current_menu_structure.md | 現行システムの画面メニュー構造（104画面） |
| table_list.md | Oracle テーブル一覧（276テーブル） |

## 02_plan / PoC 計画

| ファイル | 内容 |
|---------|------|
| poc_plan.md | リプレイス PoC 計画書（環境・検証項目・スケジュール） |
| poc_approach.md | PoC の進め方（フェーズ別タスク・評価基準） |

## 03_tech_reference / 技術参考資料

| ファイル | 内容 |
|---------|------|
| ai_legacy_improvement_guide.md | AI（Claude Code）活用のレガシー改善ガイド |
| refactoring_steps_java_oracle.md | Java/Oracle リファクタリング実行ステップ |
| oracle_is_not_old.md | Oracle 評価まとめ（古いのは技術ではなく運用） |

## 04_db_analysis / DB 調査・分析

| ファイル | 内容 |
|---------|------|
| DBロジック調査結果.md | PL/SQL 0件の発見・移行難易度評価 |
| DBロジック確認ガイド.md | DB調査に使用したSQL・手順 |
| 主要テーブルレコード数一覧.xlsx | テーブル別レコード数（最大5,400万件） |
| 外部キー制約.xlsx | 外部キー制約一覧 |
| インデックス一覧.xlsx | インデックス一覧 |
| スキーマ全体のサイズ.xlsx | スキーマサイズ（合計約480GB） |

## 05_screenshots / 画面キャプチャ

| ファイル | 内容 |
|---------|------|
| menu_screen_1.jpeg | メニュー画面（全体） |
| menu_screen_2.jpeg | メニュー画面（詳細展開） |

---

## 調査結果サマリ（重要な発見）

1. **PL/SQL が 0件** → ビジネスロジックは全て Java 側に集中。DB移行リスクは低い。
2. **独自MBBフレームワーク** → Spring 未使用。リファクタリングは非現実的 → フルリプレース推奨。
3. **月額保守 800万円**（年間約1億円） → リプレースの経済的合理性は十分。
4. **104画面 / 276テーブル** → 一人開発PoCとしては管理可能な規模。
