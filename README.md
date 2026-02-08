# 賃貸管理システム リプレイス PoC

## 概要

現行の賃貸管理システム（Java 6 / Oracle / 独自MBBフレームワーク）を Ruby on Rails + PostgreSQL でリプレイスするための PoC プロジェクト。

## 現行システム

| 項目 | 内容 |
|------|------|
| 言語 | Java 6 |
| DB | Oracle |
| フレームワーク | 独自MBBフレームワーク |
| 画面数 | 104画面 |
| テーブル数 | 276テーブル（約480GB） |
| PL/SQL | 0件（ロジックは全てJava側） |

## PoC 技術スタック

| カテゴリ | 技術 |
|---------|------|
| 言語 | Ruby 3.3 |
| フレームワーク | Rails 8.1 |
| DB | PostgreSQL 16 |
| インフラ | AWS (EC2 + RDS) |
| コンテナ | Docker |
| CI/CD | GitHub Actions |
| AI開発支援 | Claude Code |

## ディレクトリ構成

```
rental-system-poc/
├── README.md
├── docs/                          # 調査・計画ドキュメント
│   ├── 01_investigation/          # 現行システム調査結果
│   ├── 02_plan/                   # PoC計画・進め方
│   ├── 03_tech_reference/         # 技術参考資料
│   ├── 04_db_analysis/            # DB調査・分析結果
│   ├── 05_screenshots/            # 画面キャプチャ
│   └── 06_features/               # 機能仕様・設計ドキュメント
├── app/                           # Railsアプリ
├── docker-compose.yml             # PostgreSQL コンテナ定義
└── Gemfile
```

## 外部連携

| 連携先 | 方式 | 内容 |
|--------|------|------|
| OBIC7 | FTP | 会計仕訳データ連携（5本） |
| アプラス | ファイル | 口座振替依頼・結果取込（2本） |
| GoWeb | ファイル | エンド契約データ出力 |
| 保証会社 | - | 保証会社連携管理 |

## セットアップ

### 前提条件

- Ruby 3.3
- Node.js（importmap 用）
- PostgreSQL 16（ローカル起動の場合）
- Docker / Docker Compose（Docker 起動の場合）

### 環境変数の設定

```bash
cp .env.sample .env
```

`.env` に DB 接続情報や SSO クレデンシャルを記載する（`.env` は git 管理外）。
開発環境では SSO 未設定のまま「開発用ログイン」で動作可能。

### A. Docker で PostgreSQL を起動する場合（推奨）

```bash
# 1. PostgreSQL コンテナを起動
docker compose up -d

# 2. 依存ライブラリのインストール・DB作成・マイグレーション・サーバー起動
bin/setup
```

デフォルトで `localhost:5432` に `postgres/postgres` で接続します。

### B. ローカルの PostgreSQL を使う場合

```bash
# 1. PostgreSQL が起動していることを確認
pg_isready

# 2. 必要に応じて接続情報を環境変数で指定
export DB_HOST=localhost
export DB_USERNAME=your_username
export DB_PASSWORD=your_password
export DB_PORT=5432

# 3. セットアップ実行
bin/setup
```

### 開発用ユーザーの作成

初回セットアップ後、開発用ログインに使うユーザーを作成する:

```bash
bin/rails db:seed
```

以下の4名が作成される（`find_or_create_by` で冪等）:

| 名前 | メール | ロール |
|------|--------|--------|
| 管理者 | admin@example.com | admin |
| マネージャー | manager@example.com | manager |
| オペレーター | operator@example.com | operator |
| 閲覧者 | viewer@example.com | viewer |

### サーバー起動

```bash
bin/rails server
# => http://localhost:3000 でアクセス
```

ブラウザでアクセスするとログインページが表示される。
開発環境では SSO 設定不要で「開発用ログイン」セクションからログイン可能。

### テスト・Lint

```bash
bundle exec rspec    # テスト実行
bin/rubocop          # Lint チェック
```

### システムテスト（Playwright）

```bash
npx playwright install chromium   # 初回のみ
bundle exec rspec spec/system/    # システムテスト実行
```

## 認証・権限管理

SSO 認証（Microsoft Entra ID / Google OAuth2）と4段階ロール権限管理を実装済み。
詳細は [docs/06_features/07_authentication.md](docs/06_features/07_authentication.md) を参照。

### SSO 設定（環境変数）

SSO を有効にするには、以下の環境変数を設定する。未設定のプロバイダは自動的にスキップされる。

```bash
# Microsoft Entra ID
export ENTRA_CLIENT_ID=<アプリケーション（クライアント）ID>
export ENTRA_CLIENT_SECRET=<クライアントシークレット>
export ENTRA_TENANT_ID=<テナント ID>

# Google OAuth2
export GOOGLE_CLIENT_ID=<OAuth2 クライアント ID>
export GOOGLE_CLIENT_SECRET=<クライアントシークレット>
```

### 検証環境・本番環境でのユーザー作成

SSO 経由で初回ログインしたユーザーは自動的に `viewer`（閲覧のみ）ロールで作成される。
ロール変更は以下の方法で行う。

#### 方法 1: Rails console（初回の admin ユーザー作成）

```bash
# サーバーに SSH 接続後
bin/rails console

# 初回 admin ユーザーを手動作成（SSO ログイン前に作成する場合）
User.create!(
  provider: "entra_id",
  uid: "<Entra ID の Object ID>",
  name: "管理者名",
  email: "admin@your-domain.com",
  role: :admin
)

# または、SSO で viewer として作成済みのユーザーを admin に昇格
User.find_by(email: "admin@your-domain.com").update!(role: :admin)
```

#### 方法 2: 管理画面（admin ユーザーが存在する場合）

1. admin ロールのユーザーでログイン
2. ヘッダーの「ユーザー管理」リンクをクリック
3. 対象ユーザーの「ロール変更」から変更

#### 方法 3: Rake タスク（CI/CD パイプラインから実行する場合）

```bash
# 環境変数でメールアドレスとロールを指定
bin/rails runner "User.find_by(email: 'admin@your-domain.com')&.update!(role: :admin)"
```

### 権限ロール

| ロール | 権限 |
|--------|------|
| admin | 全操作（ユーザー管理含む） |
| manager | マスタ管理（建物・部屋・オーナー・契約の CRUD） |
| operator | 入出金操作（入金消込・オーナー支払処理・インポート） |
| viewer | 閲覧のみ（全画面の参照） |

## PoC スケジュール

- Phase 1: 準備（1〜2週間）
- Phase 2: 実装（3〜5週間）
- Phase 3: 評価（1週間）
