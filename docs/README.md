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
| 11_settlement.md | 11 | 解約精算（日割り・敷金返還） | 実装済 |
| 12_reports.md | 12 | 帳票・レポート（収支・エイジング・入金サマリ） | 実装済 |
| 13_approval_workflow.md | 13 | 承認ワークフロー（1段階承認） | 実装済 |
| 14_vendor_construction.md | 15 | 業者マスタ + 工事管理 | 実装済 |
| 15_contract_renewal.md | 16 | 契約更新管理 | 実装済 |
| 16_inquiry.md | 17 | 問い合わせ・修繕依頼 | 実装済 |
| 17_key_management.md | 18 | 鍵管理 | 実装済 |
| 18_insurance.md | 19 | 保険管理 | 実装済 |

### 06_features/jobs / バッチジョブ

| ファイル | 内容 | ステータス |
|---------|------|-----------|
| 01_batch_jobs.md | バッチジョブ概要 | 実装済 |
| 02_overdue_detection.md | 滞納自動検出 | 実装済 |
| 03_contract_expiration.md | 契約期限切れ | 実装済 |
| 04_room_status_sync.md | 部屋ステータス同期 | 実装済 |
| 05_monthly_payment_generation.md | 入金予定月次生成 | 実装済 |
| 06_monthly_owner_payment_generation.md | オーナー支払月次生成 | 実装済 |
| 07_master_lease_expiration.md | ML期限切れ | 実装済 |
| 08_contract_renewal_reminder.md | 契約更新リマインド | 実装済 |
| 09_insurance_expiration.md | 保険期限切れアラート | 実装済 |

## 07_coverage / テストカバレッジ

| ファイル | 内容 |
|---------|------|
| coverage_report.md | テストカバレッジレポート（行 94.9% / ブランチ 70.3%） |

## infra / インフラ構成

| ファイル | 内容 |
|---------|------|
| 01_aws_architecture.md | AWS アーキテクチャ概要 |
| 02_terraform_structure.md | Terraform 構成 |
| 03_ecs_task_definitions.md | ECS タスク定義 |
| 04_cicd_pipeline.md | CI/CD パイプライン |
| 05_monitoring.md | 監視設定 |
| 06_security.md | セキュリティ設計 |

---

## 調査結果サマリ（重要な発見）

1. **PL/SQL が 0件** → ビジネスロジックは全て Java 側に集中。DB移行リスクは低い。
2. **独自MBBフレームワーク** → Spring 未使用。リファクタリングは非現実的 → フルリプレース推奨。
3. **月額保守 800万円**（年間約1億円） → リプレースの経済的合理性は十分。
4. **104画面 / 276テーブル** → 一人開発PoCとしては管理可能な規模。

## PoC 実装進捗

- **実装済画面数:** 約70画面（CRUD×24リソース + ダッシュボード + レポート3種 + 滞納 + 一括消込 + インポート + 認証）
- **テスト数:** 554件（モデル / リクエスト / ジョブ / システム）全パス
- **テストカバレッジ:** 行 94.9% / ブランチ 70.3%
- **モデル数:** 21（Building, Room, Owner, MasterLease, ExemptionPeriod, RentRevision, Tenant, Contract, TenantPayment, OwnerPayment, Settlement, User, Approval, Vendor, Construction, ContractRenewal, Inquiry, Key, KeyHistory, Insurance + ApplicationRecord）
- **バッチジョブ:** 8件（Solid Queue）
- **CI/CD:** GitHub Actions（5ジョブ: scan_ruby, scan_js, lint, test, system-test）

## 今後の候補（未実装）

| 優先度 | 機能 | 概要 |
|--------|------|------|
| 高 | 外部連携モック | OBIC7 会計仕訳、アプラス口座振替（ファイル出力のモック実装） |
| 高 | 通知機能 | Action Mailer でメール通知（滞納・契約期限・保険期限） |
| 中 | 監査ログ | 操作履歴の記録（誰がいつ何を変更したか） |
| 中 | 本番デプロイ | Kamal で AWS EC2 + RDS にデプロイ |
| 低 | ブランチカバレッジ向上 | 現在 70.3% → 80% 目標 |
| 低 | パフォーマンス最適化 | N+1 クエリ検出（Bullet gem）、ページネーション |
