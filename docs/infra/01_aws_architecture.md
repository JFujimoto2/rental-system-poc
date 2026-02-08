# AWS アーキテクチャ設計

## 概要

賃貸管理システム PoC を AWS 上に Terraform でデプロイするための構成設計。
コンテナベース（ECS Fargate）+ マネージド DB（RDS）のサーバーレス寄り構成を採用し、
運用負荷を最小限に抑える。

## 構成図

```
                        ┌─────────────────────────────────────────┐
                        │                  VPC                     │
                        │          10.0.0.0/16                     │
Internet ──── Route53   │                                         │
              (DNS)     │  ┌─ Public Subnet (AZ-a) ─────────────┐ │
                │       │  │  NAT Gateway                        │ │
                ▼       │  │  ALB (HTTPS 終端)                   │ │
           ACM (証明書)  │  └────────────────────────────────────┘ │
                │       │  ┌─ Public Subnet (AZ-c) ─────────────┐ │
                │       │  │  NAT Gateway (冗長化)               │ │
                │       │  │  ALB (HTTPS 終端)                   │ │
                │       │  └────────────────────────────────────┘ │
                │       │                                         │
                ▼       │  ┌─ Private Subnet (AZ-a/c) ──────────┐ │
           ┌────────┐   │  │                                     │ │
           │  ALB   │───│──│─▶ ECS Fargate (web)                 │ │
           └────────┘   │  │     Puma + Thruster                 │ │
                        │  │     Auto Scaling (CPU/Memory)       │ │
                        │  │                                     │ │
                        │  │   ECS Fargate (worker)              │ │
                        │  │     Solid Queue                     │ │
                        │  │     recurring.yml スケジュール実行    │ │
                        │  └────────────────────────────────────┘ │
                        │                                         │
                        │  ┌─ Private Subnet (AZ-a/c) ──────────┐ │
                        │  │  RDS PostgreSQL 16                  │ │
                        │  │    Multi-AZ (本番)                   │ │
                        │  │    4 databases:                     │ │
                        │  │      - primary (アプリ本体)          │ │
                        │  │      - queue   (Solid Queue)        │ │
                        │  │      - cache   (Solid Cache)        │ │
                        │  │      - cable   (Solid Cable)        │ │
                        │  └────────────────────────────────────┘ │
                        │                                         │
                        │  ┌─ S3 ───────────────────────────────┐ │
                        │  │  Active Storage (ファイルアップロード)│ │
                        │  │  バックアップ / ログ保管              │ │
                        │  └────────────────────────────────────┘ │
                        └─────────────────────────────────────────┘
```

## サービス構成

### コンピュート

| サービス | 用途 | スペック目安 |
|---------|------|-------------|
| ECS Fargate (web) | Puma + Thruster | 0.5 vCPU / 1GB RAM × 2タスク |
| ECS Fargate (worker) | Solid Queue ワーカー | 0.25 vCPU / 0.5GB RAM × 1タスク |

- web はオートスケーリング対応（CPU 70% / メモリ 80% でスケールアウト）
- worker は基本1タスク（`JOB_CONCURRENCY` で並列度調整）

### データベース

| サービス | 用途 | スペック目安 |
|---------|------|-------------|
| RDS PostgreSQL 16 | アプリ DB（4 database） | db.t4g.small（開発）/ db.r6g.large（本番） |

- Multi-AZ は本番のみ有効化
- 自動バックアップ 7日保持
- Performance Insights 有効化
- 4つの database は同一 RDS インスタンス上に作成

### ネットワーク

| リソース | 設定 |
|---------|------|
| VPC | 10.0.0.0/16 |
| Public Subnet | 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-c) |
| Private Subnet (App) | 10.0.11.0/24 (AZ-a), 10.0.12.0/24 (AZ-c) |
| Private Subnet (DB) | 10.0.21.0/24 (AZ-a), 10.0.22.0/24 (AZ-c) |
| NAT Gateway | 各 AZ に1つ（本番）/ 1つのみ（開発） |
| ALB | Public Subnet に配置、HTTPS 終端 |

### ストレージ・その他

| サービス | 用途 |
|---------|------|
| S3 | Active Storage（ファイルアップロード）、DB バックアップ |
| ACM | SSL/TLS 証明書（ALB 用） |
| Route 53 | DNS 管理 |
| CloudWatch | ログ収集、メトリクス、アラーム |
| ECR | Docker イメージレジストリ |
| Secrets Manager | RAILS_MASTER_KEY、DB パスワード等 |

## 環境分離

| 環境 | 用途 | RDS | ECS タスク数 | Multi-AZ |
|------|------|-----|-------------|----------|
| dev | 開発検証 | db.t4g.micro | web:1, worker:1 | No |
| stg | ステージング | db.t4g.small | web:1, worker:1 | No |
| prod | 本番 | db.r6g.large | web:2+, worker:1 | Yes |

Terraform workspace または別ディレクトリで環境を分離する。

## コスト概算（月額・東京リージョン）

### 開発環境
| リソース | 概算 |
|---------|------|
| ECS Fargate (web + worker) | ~$15 |
| RDS db.t4g.micro | ~$15 |
| ALB | ~$20 |
| NAT Gateway | ~$35 |
| その他（S3, CloudWatch, ECR） | ~$5 |
| **合計** | **~$90/月** |

### 本番環境
| リソース | 概算 |
|---------|------|
| ECS Fargate (web×2 + worker) | ~$50 |
| RDS db.r6g.large (Multi-AZ) | ~$300 |
| ALB | ~$25 |
| NAT Gateway ×2 | ~$70 |
| その他 | ~$15 |
| **合計** | **~$460/月** |

※ リザーブド/Savings Plan 適用で 30-40% 削減可能
