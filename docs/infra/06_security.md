# セキュリティ設計

## 概要

AWS 上のセキュリティ対策をネットワーク・アクセス制御・データ保護の観点でまとめる。

## ネットワークセキュリティ

### サブネット分離

| サブネット | 配置リソース | インターネットアクセス |
|-----------|-------------|---------------------|
| Public | ALB, NAT Gateway | 直接 |
| Private (App) | ECS Fargate | NAT Gateway 経由（アウトバウンドのみ） |
| Private (DB) | RDS | なし |

- ECS タスクはインターネットから直接アクセス不可
- RDS はプライベートサブネットに隔離

### Security Group

```
ALB SG
  ├── Inbound:  443/tcp from 0.0.0.0/0 (HTTPS)
  │             80/tcp from 0.0.0.0/0 → HTTPS リダイレクト
  └── Outbound: 80/tcp to ECS SG

ECS SG
  ├── Inbound:  80/tcp from ALB SG のみ
  └── Outbound: 5432/tcp to RDS SG
                443/tcp to 0.0.0.0/0 (AWS API: ECR, Secrets Manager, CloudWatch)

RDS SG
  ├── Inbound:  5432/tcp from ECS SG のみ
  └── Outbound: なし
```

## アクセス制御

### IAM

| Role | 用途 | 主要な権限 |
|------|------|-----------|
| ecsTaskExecutionRole | ECS がタスクを起動するため | ECR Pull, CloudWatch Logs, Secrets Manager 読み取り |
| ecsTaskRole | アプリケーション実行時 | S3 (Active Storage), CloudWatch Metrics |
| deployRole | CI/CD デプロイ用 | ECR Push, ECS UpdateService |

- 最小権限の原則に従い、必要な権限のみ付与
- CI/CD は OIDC 連携（長期アクセスキーは使用しない）

### アプリケーション認証

| 機能 | 方式 |
|------|------|
| ユーザー認証 | Microsoft Entra ID / Google OAuth2 (OmniAuth) |
| セッション管理 | Rails セッション（cookie-based） |
| 権限管理 | 4ロール制（admin, manager, operator, viewer） |
| 承認フロー | operator → manager/admin の1段階承認 |

## データ保護

### 暗号化

| 対象 | 暗号化方式 |
|------|-----------|
| RDS ストレージ | AES-256 (AWS KMS) |
| RDS 通信 | SSL/TLS |
| S3 | SSE-S3 (サーバーサイド暗号化) |
| ALB 通信 | TLS 1.2+ (ACM 証明書) |
| Rails credentials | RAILS_MASTER_KEY による暗号化 |

### シークレット管理

| シークレット | 保管場所 |
|-------------|---------|
| RAILS_MASTER_KEY | AWS Secrets Manager |
| DB パスワード | AWS Secrets Manager |
| OAuth クライアント秘密鍵 | Rails credentials (暗号化済み) |

- シークレットは ECS タスク定義で `secrets` として注入
- 環境変数に平文で保持しない

### バックアップ

| 対象 | 方式 | 保持期間 |
|------|------|---------|
| RDS | 自動スナップショット | 7日（開発）/ 35日（本番） |
| RDS | 手動スナップショット | デプロイ前に取得 |
| S3 | バージョニング有効化 | 無期限 |

## Rails アプリケーション側のセキュリティ

既に実装済みの対策：

- `force_ssl` 有効（production）
- CSRF 保護（`protect_from_forgery`）
- `allow_browser versions: :modern`（古いブラウザの拒否）
- Brakeman によるセキュリティスキャン（CI で実行）
- Bundler Audit による gem 脆弱性チェック（CI で実行）
