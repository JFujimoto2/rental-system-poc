# ドキュメント一覧

## 01_investigation / 現行システム調査結果

| ファイル | 内容 |
|---------|------|
| system_investigation_checklist.md | Java 6 システム調査・判断タスク一覧 |
| additional_investigation.md | 追加調査項目チェックリスト（データ量・バッチ・外部連携） |
| current_menu_structure.md | 現行システムの画面メニュー構造（104画面） |
| sublease_business_overview.md | サブリース事業の業務概要・二重契約構造の解説 |
| table_list.md | Oracle テーブル一覧（276テーブル） |

## 02_plan / PoC 計画

| ファイル | 内容 |
|---------|------|
| poc_plan.md | リプレイス PoC 計画書（環境・検証項目・スケジュール） |
| poc_approach.md | PoC の進め方（フェーズ別タスク・評価基準） |
| screen_implementation_roadmap.md | 画面実装ロードマップ（Step 1〜13） |
| additional_features_plan.md | 追加機能計画（Step 8〜13の詳細設計） |

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

## 06_features / 機能仕様

| ファイル | Step | 内容 | ステータス |
|---------|------|------|-----------|
| 01_building_room.md | 1 | 建物・部屋 CRUD | 実装済 |
| 02_owner.md | 2 | オーナー CRUD | 実装済 |
| 03_master_lease.md | 3 | マスターリース契約（免責期間・賃料改定含む） | 実装済 |
| 04_tenant_contract.md | 4 | 入居者・転貸借契約 CRUD | 実装済 |
| 05_payment.md | 5 | 入出金管理（テナント入金・オーナー支払） | 実装済 |
| 06_excel_import.md | 6 | Excel インポート（建物・部屋一括取込） | 実装済 |
| 07_authentication.md | 7 | 認証・権限管理（Entra ID / Google OAuth2 / 4ロール） | 実装済 |
| 08_dashboard.md | 8 | ダッシュボード（業務 KPI 集約表示） | 実装済 |
| 09_delinquency.md | 9 | 滞納管理（自動検出・エイジング分類・CSV） | 実装済 |
| 10_bulk_clearing.md | 10 | 入金一括消込（CSV 照合・自動マッチング） | 実装済 |

---

## 調査結果サマリ（重要な発見）

1. **PL/SQL が 0件** → ビジネスロジックは全て Java 側に集中。DB移行リスクは低い。
2. **独自MBBフレームワーク** → Spring 未使用。リファクタリングは非現実的 → フルリプレース推奨。
3. **月額保守 800万円**（年間約1億円） → リプレースの経済的合理性は十分。
4. **104画面 / 276テーブル** → 一人開発PoCとしては管理可能な規模。

## PoC 実装進捗

- **実装済画面数:** 約45画面（CRUD + ダッシュボード + 滞納 + 一括消込 + インポート + 認証）
- **テスト数:** 277件（モデル / リクエスト / サービス / システム）
- **モデル数:** 12（Building, Room, Owner, MasterLease, ExemptionPeriod, RentRevision, Tenant, Contract, TenantPayment, OwnerPayment, User + ApplicationRecord）
