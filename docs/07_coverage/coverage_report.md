# テストカバレッジレポート

## 計測日: 2026-02-08

## サマリ

| 指標 | カバー率 | カバー / 全体 |
|------|---------|--------------|
| 行カバレッジ | **94.9%** | 1,368 / 1,442行 |
| ブランチカバレッジ | **70.3%** | 275 / 391分岐 |
| テスト数 | **554件** | 0 failures |

## テスト内訳

| カテゴリ | ディレクトリ | 内容 |
|---------|-------------|------|
| モデルスペック | `spec/models/` | バリデーション・enum・search・label・計算ロジック |
| リクエストスペック | `spec/requests/` | CRUD・検索・CSV ダウンロード |
| ジョブスペック | `spec/jobs/` | バッチジョブ8件 |
| システムスペック | `spec/system/` | Capybara + Playwright E2E テスト |

## ファイル別カバレッジ

### モデル（100%）

| ファイル | カバー率 | 行数 |
|---------|---------|------|
| app/models/application_record.rb | 100.0% | 2 |
| app/models/building.rb | 100.0% | 12 |
| app/models/room.rb | 100.0% | 17 |
| app/models/owner.rb | 100.0% | 10 |
| app/models/master_lease.rb | 100.0% | 25 |
| app/models/exemption_period.rb | 100.0% | 5 |
| app/models/rent_revision.rb | 100.0% | 5 |
| app/models/tenant.rb | 100.0% | 9 |
| app/models/contract.rb | 100.0% | 26 |
| app/models/tenant_payment.rb | 100.0% | 21 |
| app/models/owner_payment.rb | 100.0% | 18 |
| app/models/settlement.rb | 100.0% | 21 |
| app/models/user.rb | 100.0% | 27 |
| app/models/approval.rb | 94.7% | 19 |
| app/models/vendor.rb | 100.0% | 8 |
| app/models/construction.rb | 100.0% | 28 |
| app/models/contract_renewal.rb | 100.0% | 14 |
| app/models/inquiry.rb | 100.0% | 28 |
| app/models/key.rb | 100.0% | 20 |
| app/models/key_history.rb | 100.0% | 9 |
| app/models/insurance.rb | 100.0% | 25 |

### コントローラ

| ファイル | カバー率 | 行数 |
|---------|---------|------|
| app/controllers/application_controller.rb | 82.6% | 23 |
| app/controllers/sessions_controller.rb | 72.2% | 18 |
| app/controllers/dashboard_controller.rb | 100.0% | 15 |
| app/controllers/buildings_controller.rb | 91.1% | 45 |
| app/controllers/rooms_controller.rb | 91.1% | 45 |
| app/controllers/owners_controller.rb | 91.1% | 45 |
| app/controllers/tenants_controller.rb | 94.6% | 37 |
| app/controllers/master_leases_controller.rb | 94.6% | 37 |
| app/controllers/contracts_controller.rb | 95.1% | 41 |
| app/controllers/tenant_payments_controller.rb | 94.6% | 37 |
| app/controllers/owner_payments_controller.rb | 94.6% | 37 |
| app/controllers/settlements_controller.rb | 84.2% | 38 |
| app/controllers/delinquencies_controller.rb | 84.8% | 33 |
| app/controllers/bulk_clearings_controller.rb | 100.0% | 29 |
| app/controllers/imports_controller.rb | 91.2% | 34 |
| app/controllers/approvals_controller.rb | 95.0% | 20 |
| app/controllers/reports_controller.rb | 100.0% | 88 |
| app/controllers/users_controller.rb | 57.1% | 14 |
| app/controllers/vendors_controller.rb | 95.0% | 40 |
| app/controllers/constructions_controller.rb | 95.0% | 40 |
| app/controllers/contract_renewals_controller.rb | 95.2% | 42 |
| app/controllers/inquiries_controller.rb | 95.0% | 40 |
| app/controllers/keys_controller.rb | 95.0% | 40 |
| app/controllers/insurances_controller.rb | 95.0% | 40 |

### ジョブ（100%）

| ファイル | カバー率 | 行数 |
|---------|---------|------|
| app/jobs/application_job.rb | 100.0% | 1 |
| app/jobs/overdue_detection_job.rb | 100.0% | 6 |
| app/jobs/contract_expiration_job.rb | 100.0% | 9 |
| app/jobs/master_lease_expiration_job.rb | 100.0% | 11 |
| app/jobs/room_status_sync_job.rb | 100.0% | 23 |
| app/jobs/monthly_payment_generation_job.rb | 100.0% | 11 |
| app/jobs/monthly_owner_payment_generation_job.rb | 100.0% | 11 |
| app/jobs/contract_renewal_reminder_job.rb | 100.0% | 9 |
| app/jobs/insurance_expiration_job.rb | 100.0% | 6 |

### サービス

| ファイル | カバー率 | 行数 |
|---------|---------|------|
| app/services/bulk_clearing_matcher.rb | 100.0% | 32 |
| app/services/excel_importer/base_importer.rb | 91.9% | 37 |
| app/services/excel_importer/building_importer.rb | 100.0% | 13 |
| app/services/excel_importer/room_importer.rb | 100.0% | 20 |

### ヘルパー

| ファイル | カバー率 | 行数 |
|---------|---------|------|
| app/helpers/application_helper.rb | 85.7% | 14 |
| app/helpers/buildings_helper.rb | 100.0% | 1 |
| app/helpers/rooms_helper.rb | 100.0% | 1 |
| app/helpers/owners_helper.rb | 100.0% | 1 |
| app/helpers/tenants_helper.rb | 100.0% | 1 |
| app/helpers/contracts_helper.rb | 100.0% | 1 |
| app/helpers/master_leases_helper.rb | 100.0% | 1 |
| app/helpers/tenant_payments_helper.rb | 100.0% | 1 |
| app/helpers/owner_payments_helper.rb | 100.0% | 1 |

### その他

| ファイル | カバー率 | 行数 | 備考 |
|---------|---------|------|------|
| app/mailers/application_mailer.rb | 0.0% | 4 | メール機能未使用（デフォルト生成ファイル） |

## カバー率の低いファイルの分析

| ファイル | カバー率 | 未カバー理由 |
|---------|---------|-------------|
| `application_mailer.rb` | 0.0% | Rails デフォルト生成ファイル。メール送信機能は未実装。 |
| `users_controller.rb` | 57.1% | 管理者限定のユーザー管理機能。システムテストで主要パスのみカバー。 |
| `sessions_controller.rb` | 72.2% | OAuth コールバック処理。テスト環境では OmniAuth mock を使用するため、一部の実パスが未通過。 |
| `application_controller.rb` | 82.6% | 認可エラーハンドリング（権限不足時のリダイレクト等）の一部分岐が未カバー。 |
| `settlements_controller.rb` | 84.2% | 精算の自動計算ロジックの一部分岐（敷金精算の nil ガード等）。 |

## 計測方法

- **ツール:** SimpleCov 0.22.0（`simplecov` gem）
- **設定:** `SimpleCov.start 'rails'` + `enable_coverage :branch`
- **除外:** `spec/`, `config/`, `db/` ディレクトリ
- **実行:** `bundle exec rspec`（全 554 テスト実行後に自動生成）
- **HTML レポート:** `coverage/index.html`（ローカルで閲覧可能）
