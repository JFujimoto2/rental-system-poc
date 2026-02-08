# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

現行の賃貸管理システム（Java 6 / Oracle / 独自MBBフレームワーク）を Rails + PostgreSQL でリプレイスするための PoC。
現行システムは 2,653ファイル / 835,115行、104画面、276テーブル（約480GB）の規模。

技術スタック: Rails 8.1 / Ruby 3.3 / PostgreSQL 16 / Docker / AWS (EC2 + RDS) / GitHub Actions / Claude Code

### 実装済み機能（Step 1〜19）

| Step | 機能 | モデル |
|------|------|--------|
| 1 | 建物・部屋 CRUD | Building, Room |
| 2 | オーナー CRUD | Owner |
| 3 | マスターリース契約（免責期間・賃料改定） | MasterLease, ExemptionPeriod, RentRevision |
| 4 | 入居者・転貸借契約 | Tenant, Contract |
| 5 | 入出金管理 | TenantPayment, OwnerPayment |
| 6 | Excel インポート（建物・部屋） | — |
| 7 | 認証（Entra ID / Google OAuth2 / 4ロール） | User |
| 7.5 | 検索 + CSV ダウンロード（全画面） | — |
| 8 | ダッシュボード（KPI） | — |
| 9 | 滞納管理（エイジング・CSV） | — |
| 10 | 入金一括消込（CSV 照合） | — |
| 11 | 解約精算（日割り・敷金返還） | Settlement |
| 12 | 帳票（収支・エイジング・入金サマリ） | — |
| 13 | 承認ワークフロー（1段階） | Approval |
| 14 | バッチジョブ 8件 | — |
| 15 | 業者マスタ + 工事管理 | Vendor, Construction |
| 16 | 契約更新管理 | ContractRenewal |
| 17 | 問い合わせ・修繕依頼 | Inquiry |
| 18 | 鍵管理 | Key, KeyHistory |
| 19 | 保険管理 | Insurance |

**実績:** 21モデル / 約70画面 / 554テスト（行カバレッジ 94.9%）/ バッチジョブ 8件

### 今後の候補（未実装）

| 優先度 | 機能 | 概要 |
|--------|------|------|
| 高 | 外部連携モック | OBIC7 会計仕訳、アプラス口座振替（ファイル出力のモック実装） |
| 高 | 通知機能 | Action Mailer でメール通知（滞納・契約期限・保険期限） |
| 中 | 監査ログ | 操作履歴の記録（誰がいつ何を変更したか） |
| 中 | 本番デプロイ | Kamal で AWS EC2 + RDS にデプロイ |
| 低 | ブランチカバレッジ向上 | 現在 70.3% → 80% 目標 |
| 低 | パフォーマンス最適化 | N+1 クエリ検出（Bullet gem）、ページネーション |

### 外部連携（本番移行時に対応）
- OBIC7: FTP で会計仕訳データ連携（5本）
- アプラス: ファイルで口座振替依頼・結果取込（2本）
- GoWeb: ファイルでエンド契約データ出力
- 保証会社: 保証会社連携管理

### ドキュメント構成
- `docs/01_investigation/` — 現行システム調査結果（git 管理外・ローカルのみ）
- `docs/02_plan/` — PoC計画・ロードマップ・今後の候補
- `docs/03_tech_reference/` — 技術参考資料
- `docs/04_db_analysis/` — DB調査・分析結果
- `docs/05_screenshots/` — 画面キャプチャ
- `docs/06_features/` — 機能仕様（各 Step のドキュメント）
- `docs/06_features/jobs/` — バッチジョブ仕様（9件）
- `docs/07_coverage/` — テストカバレッジレポート
- `docs/infra/` — AWS インフラ構成（Terraform / ECS / CI/CD / 監視 / セキュリティ）

## Common Commands

### Development
```bash
bin/setup                    # Bootstrap environment (installs deps, prepares DB, starts server)
bin/setup --skip-server      # Setup without starting server
bin/rails server             # Start Puma on port 3000
bin/dev                      # Alias for bin/rails server
```

### Testing
```bash
bundle exec rspec                        # Run all specs (model, request, system)
bundle exec rspec spec/models/           # Run model specs
bundle exec rspec spec/requests/         # Run request specs
bundle exec rspec spec/system/           # Run system specs (Playwright)
bundle exec rspec spec/models/room_spec.rb       # Run a single spec file
bundle exec rspec spec/models/room_spec.rb:10    # Run a specific example by line number
```

### System Tests (Playwright)

画面の E2E テストには Capybara + Playwright（headless Chromium）を使用。
`spec/system/` 配下に `type: :system` のスペックを配置する。

```bash
npx playwright install chromium          # ブラウザのインストール（初回のみ）
bundle exec rspec spec/system/           # システムテストのみ実行
```

### Code Quality
```bash
bin/rubocop                  # Lint (rubocop-rails-omakase style)
bin/rubocop -a               # Auto-fix lint issues
bin/brakeman --no-pager      # Security scan
bin/bundler-audit             # Gem vulnerability audit
bin/importmap audit          # JS dependency audit
```

### Full CI Pipeline (locally)
```bash
bin/ci                       # Runs: rubocop, bundler-audit, importmap audit, brakeman, tests, seed check
```

### Database
```bash
bin/rails db:prepare         # Create + migrate (idempotent)
bin/rails db:migrate         # Run pending migrations
bin/rails db:seed            # Load seed data
```

## Architecture

- **Framework:** Rails 8.1 with `load_defaults 8.1`
- **Frontend:** Hotwire (Turbo + Stimulus) via ImportMap — no JS build step
- **Asset pipeline:** Propshaft
- **Database:** PostgreSQL (single DB in dev/test; multi-DB in production for primary, cache, queue, cable)
- **Background jobs:** Solid Queue (database-backed, runs in Puma process via `SOLID_QUEUE_IN_PUMA`)
- **Cache:** Solid Cache (database-backed in production, memory store in dev)
- **Action Cable:** Solid Cable (database-backed)
- **Testing:** RSpec + FactoryBot + shoulda-matchers + Capybara + Playwright
- **Deployment:** Docker + Kamal; Dockerfile uses multi-stage build with jemalloc and Thruster

## Key Configuration

- **Locale:** デフォルトは日本語 (`config.i18n.default_locale = :ja`)、タイムゾーンは `Asia/Tokyo`
- `lib/` is autoloaded (except `lib/assets` and `lib/tasks`)
- Production enforces modern browsers (webp, import maps, CSS nesting support)
- CI sets `ENV['CI']` which enables eager loading in test environment
- RuboCop uses `rubocop-rails-omakase` (Rails community conventions)
- GitHub Actions CI runs: brakeman, importmap audit, rubocop, tests, and system tests (separate jobs)

## Development Workflow

TDD（テスト駆動開発）で進める。新しい機能・変更を実装する際は以下の順序に従うこと:

1. **Red** — 先にテスト（spec）を書き、失敗することを確認する
2. **Green** — テストが通る最小限の実装を行う
3. **Refactor** — テストが通った状態でリファクタリングする

- 実装コードを書く前に、必ず対応する spec を先に作成する
- `bundle exec rspec` で全テスト通過を確認してから次のステップに進む
- `bin/rubocop` で lint 違反がないことも合わせて確認する
