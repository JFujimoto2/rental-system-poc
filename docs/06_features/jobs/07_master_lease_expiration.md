# MasterLeaseExpirationJob — マスターリースステータス更新

## ステータス: 未着手

## 概要

`end_date` を過ぎた MasterLease を `terminated` に遷移し、配下の契約にも連動する日次バッチ。

## 現状の問題

- MasterLease の end_date を過ぎても手動変更が必要
- 配下の契約や部屋のステータスが連動しない

## 処理内容

**対象:** `MasterLease`
**条件:** `status: :active` かつ `end_date` が設定済みで `end_date < Date.current`
**更新:** `status` → `:terminated`
**連動:** 配下の active/scheduled_termination な Contract も `terminated` に更新

```ruby
MasterLease.where(status: :active)
           .where.not(end_date: nil)
           .where("end_date < ?", Date.current)
           .find_each do |ml|
  ml.update!(status: :terminated)
  ml.contracts.where(status: [:active, :scheduled_termination]).find_each do |contract|
    contract.update!(status: :terminated)
  end
end
```

※ 部屋ステータスの更新は RoomStatusSyncJob に委譲（依存順序で後続実行）

## 冪等性

- 対象は `status: :active` のみ → 既に `terminated` のレコードは対象外
- 再実行しても二重処理されない

## 影響範囲

- MasterLease の終了が配下の契約に自動連鎖
- RoomStatusSyncJob と組み合わせて部屋のステータスも整合

## 実行スケジュール

- 頻度: 日次
- 推奨時刻: 毎日 0:15
- 依存: ContractExpirationJob・RoomStatusSyncJob より先に実行

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/master_lease_expiration_job.rb` | ジョブクラス |
| `spec/jobs/master_lease_expiration_job_spec.rb` | テスト |
