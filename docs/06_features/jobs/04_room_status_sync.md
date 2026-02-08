# RoomStatusSyncJob — 部屋ステータス同期

## ステータス: 未着手

## 概要

契約ステータスの変化に応じて部屋のステータスを自動で同期する日次バッチ。

## 現状の問題

- 契約が `terminated` になっても部屋が `occupied` のまま
- 契約が `scheduled_termination` になっても部屋が `notice` に変わらない
- 入居率がダッシュボードで不正確になる

## 処理内容

### 1. 退去予定の同期

`scheduled_termination` の契約がある部屋を `notice` に更新する。

```ruby
Contract.where(status: :scheduled_termination).find_each do |contract|
  contract.room.update!(status: :notice) if contract.room.occupied?
end
```

### 2. 空室の同期

active/scheduled_termination な契約が0件の部屋を `vacant` に更新する。

```ruby
Room.where(status: [:occupied, :notice]).find_each do |room|
  active_contracts = room.contracts.where(status: [:active, :scheduled_termination]).count
  room.update!(status: :vacant) if active_contracts.zero?
end
```

## 冪等性

- 現在の契約状況に基づいて部屋の状態を判定
- 何度実行しても同じ結果になる

## 影響範囲

- 入居率の正確性が向上
- ダッシュボードの空室数・退去予定数が正確になる

## 実行スケジュール

- 頻度: 日次
- 推奨時刻: 毎日 0:10
- 依存: ContractExpirationJob の後に実行（契約終了を先に処理してから部屋を同期）

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/room_status_sync_job.rb` | ジョブクラス |
| `spec/jobs/room_status_sync_job_spec.rb` | テスト |
