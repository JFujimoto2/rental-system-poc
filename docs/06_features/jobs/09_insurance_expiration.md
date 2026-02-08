# InsuranceExpirationJob — 保険期限切れ検知

## ステータス: 実装済

## 概要

保険の終了日が30日以内に迫っている active 保険の status を `expiring_soon` に
自動更新する日次バッチ。

## 処理内容

**対象:** `Insurance`
**条件:** `status: :active` かつ `end_date <= 30.days.from_now`
**更新:** `status` → `:expiring_soon`

```ruby
Insurance.where(status: :active)
         .where("end_date <= ?", 30.days.from_now.to_date)
         .update_all(status: Insurance.statuses[:expiring_soon])
```

## 冪等性

- 対象は `status: :active` のみ → 既に `expiring_soon` に更新済みのレコードは対象外
- 再実行しても二重処理されない

## 影響範囲

- 保険一覧で「期限間近」ステータスでの絞り込みが可能になる
- 管理者が期限前に更新手続きを開始できる

## 実行スケジュール

- 頻度: 日次
- 推奨時刻: 毎日 0:25

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/insurance_expiration_job.rb` | ジョブクラス |
| `spec/jobs/insurance_expiration_job_spec.rb` | テスト |
