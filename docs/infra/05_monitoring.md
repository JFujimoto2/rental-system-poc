# 監視・ログ・アラート

## 概要

CloudWatch を中心に、アプリケーション・インフラの監視体制を構築する。

## ログ

### CloudWatch Logs グループ

| ロググループ | ソース | 保持期間 |
|-------------|--------|---------|
| `/ecs/rental-system-poc/web` | Puma アクセスログ、Rails ログ | 30日 |
| `/ecs/rental-system-poc/worker` | Solid Queue ジョブログ | 30日 |
| `/rds/rental-system-poc` | PostgreSQL スロークエリログ | 14日 |

### ジョブ実行ログ

各バッチジョブは `Rails.logger.info` で処理件数を出力する：

```
[OverdueDetectionJob] 5件の未入金を滞納に更新しました
[ContractExpirationJob] 2件の契約を解約済に更新しました
[RoomStatusSyncJob] 退去予定: 1件, 空室化: 3件
[MonthlyPaymentGenerationJob] 45件の入金予定を生成しました
```

CloudWatch Logs Insights でジョブの実行履歴を検索可能：

```
fields @timestamp, @message
| filter @message like /Job\]/
| sort @timestamp desc
| limit 50
```

## メトリクス・アラーム

### ECS

| メトリクス | 閾値 | アクション |
|-----------|------|-----------|
| CPUUtilization (web) | > 80% (5分) | SNS 通知 + Auto Scaling |
| MemoryUtilization (web) | > 85% (5分) | SNS 通知 |
| RunningTaskCount (web) | < 1 (1分) | SNS 通知（緊急） |
| RunningTaskCount (worker) | < 1 (5分) | SNS 通知（緊急） |

### RDS

| メトリクス | 閾値 | アクション |
|-----------|------|-----------|
| CPUUtilization | > 80% (5分) | SNS 通知 |
| FreeStorageSpace | < 5 GB | SNS 通知 |
| DatabaseConnections | > 80% of max | SNS 通知 |
| ReadLatency / WriteLatency | > 100ms (5分) | SNS 通知 |

### ALB

| メトリクス | 閾値 | アクション |
|-----------|------|-----------|
| HTTPCode_Target_5XX_Count | > 10 (5分) | SNS 通知 |
| TargetResponseTime | > 3s (5分) | SNS 通知 |
| HealthyHostCount | < 1 (1分) | SNS 通知（緊急） |

## 通知先

| 優先度 | 通知先 | 用途 |
|--------|--------|------|
| 緊急 | メール + Slack | サービス停止、タスク全滅 |
| 警告 | Slack | 高 CPU、メモリ逼迫、5xx 増加 |
| 情報 | CloudWatch のみ | デプロイ完了、ジョブ実行 |

## ダッシュボード

CloudWatch ダッシュボードで以下を一画面に集約：

- ECS タスク数・CPU・メモリ使用率
- RDS 接続数・CPU・ストレージ残量
- ALB リクエスト数・レスポンスタイム・エラー率
- ジョブ実行状況（Logs Insights ウィジェット）
