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
│   └── 05_screenshots/            # 画面キャプチャ
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

### サーバー起動

```bash
bin/rails server
# => http://localhost:3000 でアクセス
```

### テスト・Lint

```bash
bundle exec rspec    # テスト実行
bin/rubocop          # Lint チェック
```

## PoC スケジュール

- Phase 1: 準備（1〜2週間）
- Phase 2: 実装（3〜5週間）
- Phase 3: 評価（1週間）
