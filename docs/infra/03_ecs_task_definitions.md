# ECS タスク定義

## 概要

web（Puma）と worker（Solid Queue）の2つのタスク定義を作成する。
同一の Docker イメージを使用し、コマンドのみ異なる。

## web タスク定義

```json
{
  "family": "rental-system-poc-web",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "web",
      "image": "<account>.dkr.ecr.ap-northeast-1.amazonaws.com/rental-system-poc:latest",
      "command": ["./bin/thrust", "./bin/rails", "server", "-b", "0.0.0.0"],
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        { "name": "RAILS_ENV", "value": "production" },
        { "name": "RAILS_LOG_TO_STDOUT", "value": "true" },
        { "name": "SOLID_QUEUE_IN_PUMA", "value": "false" },
        { "name": "WEB_CONCURRENCY", "value": "2" },
        { "name": "RAILS_MAX_THREADS", "value": "5" }
      ],
      "secrets": [
        { "name": "RAILS_MASTER_KEY", "valueFrom": "arn:aws:secretsmanager:::secret:rails-master-key" },
        { "name": "DB_HOST", "valueFrom": "arn:aws:secretsmanager:::secret:db-host" },
        { "name": "DB_USERNAME", "valueFrom": "arn:aws:secretsmanager:::secret:db-username" },
        { "name": "DB_PASSWORD", "valueFrom": "arn:aws:secretsmanager:::secret:db-password" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/rental-system-poc/web",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "web"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/up || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

### ポイント
- `SOLID_QUEUE_IN_PUMA=false` で web プロセスではジョブを実行しない
- `WEB_CONCURRENCY=2` で Puma のワーカープロセス数を指定
- ヘルスチェックは Rails 標準の `/up` エンドポイントを使用
- シークレットは Secrets Manager から注入

## worker タスク定義

```json
{
  "family": "rental-system-poc-worker",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "worker",
      "image": "<account>.dkr.ecr.ap-northeast-1.amazonaws.com/rental-system-poc:latest",
      "command": ["bundle", "exec", "rake", "solid_queue:start"],
      "environment": [
        { "name": "RAILS_ENV", "value": "production" },
        { "name": "RAILS_LOG_TO_STDOUT", "value": "true" },
        { "name": "JOB_CONCURRENCY", "value": "1" },
        { "name": "RAILS_MAX_THREADS", "value": "5" }
      ],
      "secrets": [
        { "name": "RAILS_MASTER_KEY", "valueFrom": "arn:aws:secretsmanager:::secret:rails-master-key" },
        { "name": "DB_HOST", "valueFrom": "arn:aws:secretsmanager:::secret:db-host" },
        { "name": "DB_USERNAME", "valueFrom": "arn:aws:secretsmanager:::secret:db-username" },
        { "name": "DB_PASSWORD", "valueFrom": "arn:aws:secretsmanager:::secret:db-password" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/rental-system-poc/worker",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "worker"
        }
      }
    }
  ]
}
```

### ポイント
- ポートマッピングなし（外部からのアクセス不要）
- `JOB_CONCURRENCY=1` でワーカースレッド数を制御
- `recurring.yml` のスケジュールに従い自動でバッチジョブを実行
- web より小さいリソース（0.25 vCPU / 0.5 GB）

## Security Group

```
ALB SG:
  Inbound:  443 (HTTPS) from 0.0.0.0/0
  Outbound: 80 to ECS SG

ECS SG:
  Inbound:  80 from ALB SG
  Outbound: 5432 to RDS SG
            443 to 0.0.0.0/0 (ECR, Secrets Manager, CloudWatch)

RDS SG:
  Inbound:  5432 from ECS SG
  Outbound: なし
```

## Auto Scaling（web のみ）

```hcl
# CPU 使用率 70% でスケールアウト
resource "aws_appautoscaling_target" "web" {
  max_capacity       = var.web_max_count
  min_capacity       = var.web_min_count
  resource_id        = "service/${cluster_name}/${service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web_cpu" {
  name               = "cpu-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```
