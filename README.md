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
├── app/                           # Railsアプリ（今後作成）
├── docker-compose.yml             # （今後作成）
└── Gemfile                        # （今後作成）
```

## 外部連携

| 連携先 | 方式 | 内容 |
|--------|------|------|
| OBIC7 | FTP | 会計仕訳データ連携（5本） |
| アプラス | ファイル | 口座振替依頼・結果取込（2本） |
| GoWeb | ファイル | エンド契約データ出力 |
| 保証会社 | - | 保証会社連携管理 |

## セットアップ

```bash
# 今後記載
```

## PoC スケジュール

- Phase 1: 準備（1〜2週間）
- Phase 2: 実装（3〜5週間）
- Phase 3: 評価（1週間）
