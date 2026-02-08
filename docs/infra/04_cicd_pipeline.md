# CI/CD パイプライン

## 概要

GitHub Actions で CI（テスト・lint）と CD（ECR Push + ECS デプロイ）を実行する。
現在の CI 設定をベースに、デプロイステップを追加する。

## パイプライン全体像

```
Push to main
  ↓
┌─ CI ─────────────────────────────────┐
│  1. RuboCop (lint)                   │
│  2. Bundler Audit (gem 脆弱性)        │
│  3. Importmap Audit (JS 脆弱性)       │
│  4. Brakeman (セキュリティスキャン)     │
│  5. RSpec (model + request)          │  ← 並列実行
│  6. RSpec (system / Playwright)      │
└──────────────────────────────────────┘
  ↓ 全パス
┌─ CD ─────────────────────────────────┐
│  7. Docker Build                     │
│  8. ECR Push                         │
│  9. ECS Deploy (web + worker)        │
└──────────────────────────────────────┘
```

## GitHub Actions ワークフロー（CD 部分）

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  ci:
    # 既存の CI ジョブ（rubocop, brakeman, tests, system-tests）
    # ...

  deploy:
    needs: ci
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
          aws-region: ap-northeast-1

      - name: Login to ECR
        id: ecr-login
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.ecr-login.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/rental-system-poc:$IMAGE_TAG .
          docker tag $ECR_REGISTRY/rental-system-poc:$IMAGE_TAG $ECR_REGISTRY/rental-system-poc:latest
          docker push $ECR_REGISTRY/rental-system-poc:$IMAGE_TAG
          docker push $ECR_REGISTRY/rental-system-poc:latest

      - name: Deploy web to ECS
        run: |
          aws ecs update-service \
            --cluster rental-system-poc-prod \
            --service web \
            --force-new-deployment

      - name: Deploy worker to ECS
        run: |
          aws ecs update-service \
            --cluster rental-system-poc-prod \
            --service worker \
            --force-new-deployment

      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster rental-system-poc-prod \
            --services web worker
```

## 必要な GitHub Secrets

| Secret | 説明 |
|--------|------|
| `AWS_DEPLOY_ROLE_ARN` | OIDC で AssumeRole する IAM Role の ARN |

※ OIDC 連携を使用し、長期的な AWS アクセスキーは保持しない

## マイグレーション戦略

ECS タスクはコンテナ起動時に `bin/docker-entrypoint` で `db:prepare` を実行する。
ただし、複数タスクが同時起動する場合の競合を避けるため、
本番では以下のいずれかの方法を採用する：

### 方法 A: デプロイ前の1回限りタスク実行（推奨）

```bash
# デプロイ前にマイグレーション専用タスクを実行
aws ecs run-task \
  --cluster rental-system-poc-prod \
  --task-definition rental-system-poc-migrate \
  --launch-type FARGATE \
  --network-configuration "..." \
  --overrides '{"containerOverrides":[{"name":"web","command":["bin/rails","db:migrate"]}]}'
```

### 方法 B: Entrypoint で排他制御

`bin/docker-entrypoint` にアドバイザリーロックを追加し、
最初に起動したタスクのみマイグレーションを実行する。

## ロールバック

ECS のローリングデプロイにより、新タスクのヘルスチェックが失敗した場合は
自動で旧タスクにロールバックされる。

手動ロールバックが必要な場合：

```bash
# 前のタスク定義リビジョンに戻す
aws ecs update-service \
  --cluster rental-system-poc-prod \
  --service web \
  --task-definition rental-system-poc-web:<前のリビジョン番号>
```
