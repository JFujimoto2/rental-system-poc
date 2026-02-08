# Terraform ディレクトリ構成

## 概要

環境別に変数ファイルで切り替えるモジュール構成を採用する。

## ディレクトリ構成

```
infra/
├── README.md
├── modules/
│   ├── vpc/                    # VPC, Subnet, NAT, IGW
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/                    # ECR リポジトリ
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecs/                    # ECS Cluster, Service, Task Definition
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/                    # RDS PostgreSQL
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/                    # ALB, Target Group, Listener
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/                     # S3 バケット（Active Storage, バックアップ）
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/               # Security Group, IAM Role/Policy
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/             # CloudWatch, SNS アラーム
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── envs/
│   ├── dev/
│   │   ├── main.tf             # モジュール呼び出し
│   │   ├── variables.tf
│   │   ├── terraform.tfvars    # 環境固有値
│   │   ├── backend.tf          # S3 backend
│   │   └── outputs.tf
│   ├── stg/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── backend.tf
│       └── outputs.tf
└── shared/
    └── backend-setup/          # Terraform state 用 S3 + DynamoDB
        └── main.tf
```

## モジュール概要

### vpc
- VPC、Public/Private Subnet（2AZ）
- Internet Gateway、NAT Gateway
- Route Table

### ecr
- Docker イメージリポジトリ
- ライフサイクルポリシー（古いイメージの自動削除）

### ecs
- ECS Cluster（Fargate）
- web サービス（Task Definition + Service + Auto Scaling）
- worker サービス（Task Definition + Service）
- CloudWatch Logs グループ

### rds
- RDS PostgreSQL 16 インスタンス
- DB Subnet Group
- パラメータグループ（`log_statement: all` 等）
- 自動バックアップ設定

### alb
- Application Load Balancer
- Target Group（ECS web サービス向け）
- HTTPS Listener（ACM 証明書）
- HTTP → HTTPS リダイレクト

### s3
- Active Storage 用バケット
- DB バックアップ用バケット
- バケットポリシー、暗号化設定

### security
- Security Group（ALB / ECS / RDS）
- IAM Role（ECS Task Execution Role, Task Role）
- Secrets Manager（RAILS_MASTER_KEY, DB パスワード）

### monitoring
- CloudWatch アラーム（CPU, メモリ, DB 接続数, 5xx エラー率）
- SNS トピック（アラート通知先）
- CloudWatch Logs（ECS コンテナログ）

## 環境変数（terraform.tfvars）

```hcl
# envs/dev/terraform.tfvars の例
project_name    = "rental-system-poc"
environment     = "dev"
aws_region      = "ap-northeast-1"

# VPC
vpc_cidr        = "10.0.0.0/16"
az_count        = 2

# ECS
web_cpu         = 512     # 0.5 vCPU
web_memory      = 1024    # 1 GB
web_desired     = 1
worker_cpu      = 256     # 0.25 vCPU
worker_memory   = 512     # 0.5 GB

# RDS
db_instance_class = "db.t4g.micro"
db_multi_az       = false
db_backup_days    = 7

# Auto Scaling
web_min_count   = 1
web_max_count   = 2
```

## State 管理

Terraform state は S3 + DynamoDB で管理する。

```hcl
# envs/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "rental-system-poc-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "rental-system-poc-tfstate-lock"
    encrypt        = true
  }
}
```

## デプロイフロー

```
1. Terraform で AWS リソースを構築
     $ cd infra/envs/dev
     $ terraform init
     $ terraform plan
     $ terraform apply

2. ECR に Docker イメージを Push
     $ docker build -t rental-system-poc .
     $ docker tag rental-system-poc:latest <account>.dkr.ecr.ap-northeast-1.amazonaws.com/rental-system-poc:latest
     $ docker push <account>.dkr.ecr.ap-northeast-1.amazonaws.com/rental-system-poc:latest

3. ECS サービスを更新（新イメージでデプロイ）
     $ aws ecs update-service --cluster rental-system-poc-dev \
         --service web --force-new-deployment
     $ aws ecs update-service --cluster rental-system-poc-dev \
         --service worker --force-new-deployment
```

※ CI/CD（GitHub Actions）で自動化する場合は別途パイプライン定義が必要
