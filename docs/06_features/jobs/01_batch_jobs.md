# バッチジョブ（定期実行タスク）

## ステータス: 実装済

## 概要

日次・月次で自動実行すべき定期タスクを Solid Queue ジョブとして実装する。
現状、ステータス更新はすべて手動操作またはクエリ時の判定に依存しており、
データの整合性やダッシュボードの正確性に影響が出る可能性がある。

## 現状の課題

| 課題 | 現状の動作 | あるべき姿 |
|------|----------|-----------|
| 滞納検出 | Delinquencies画面のクエリ時に `unpaid + due_date < today` を判定 | status を `overdue` に実際に更新 |
| 契約終了 | 解約日を過ぎても `scheduled_termination` のまま | `end_date` 超過で `terminated` に自動遷移 |
| 部屋ステータス | 契約が終了しても手動で部屋の状態を変更 | 契約終了時に自動で `vacant` に更新 |
| 入金予定生成 | 手動で1件ずつ作成 | 月次で active 契約から翌月分を一括生成 |
| オーナー支払生成 | 手動で1件ずつ作成 | 月次で active な MasterLease から翌月分を一括生成 |
| MLステータス | `end_date` を過ぎても手動変更が必要 | 自動で `terminated` に遷移、配下契約にも連動 |

## ジョブ一覧

| # | ジョブ | 頻度 | 推奨実行時刻 | 優先度 | ドキュメント |
|---|--------|------|-------------|--------|-------------|
| 1 | OverdueDetectionJob | 日次 | 毎日 0:00 | 高 | [02_overdue_detection.md](02_overdue_detection.md) |
| 2 | ContractExpirationJob | 日次 | 毎日 0:05 | 高 | [03_contract_expiration.md](03_contract_expiration.md) |
| 3 | RoomStatusSyncJob | 日次 | 毎日 0:10 | 高 | [04_room_status_sync.md](04_room_status_sync.md) |
| 4 | MonthlyPaymentGenerationJob | 月次 | 毎月25日 1:00 | 中 | [05_monthly_payment_generation.md](05_monthly_payment_generation.md) |
| 5 | MonthlyOwnerPaymentGenerationJob | 月次 | 毎月25日 1:05 | 中 | [06_monthly_owner_payment_generation.md](06_monthly_owner_payment_generation.md) |
| 6 | MasterLeaseExpirationJob | 日次 | 毎日 0:15 | 低 | [07_master_lease_expiration.md](07_master_lease_expiration.md) |

## 依存順序

```
MasterLeaseExpirationJob
  ↓
ContractExpirationJob
  ↓
RoomStatusSyncJob（契約・ML終了後に部屋を同期）
  ↓
OverdueDetectionJob（独立、順不同）
```

## 技術方針

- **Solid Queue** を使用（Rails 8.1 標準、DB バック、既に設定済み）
- `app/jobs/` にジョブクラスを配置
- `config/recurring.yml` で定期実行スケジュールを定義
- ジョブの冪等性を担保（再実行しても二重処理されない設計）
- 更新件数をログ出力（運用監視用）
- TDD で実装（ジョブスペック → 実装）
