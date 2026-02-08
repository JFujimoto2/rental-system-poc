# MonthlyOwnerPaymentGenerationJob — オーナー支払自動生成

## ステータス: 実装済

## 概要

active な MasterLease から翌月分の OwnerPayment を一括生成する月次バッチ。

## 現状の問題

- オーナー支払（OwnerPayment）を手動で1件ずつ作成している
- 毎月の定型作業で、マスターリース数が増えるほど負担が大きくなる

## 処理内容

**対象:** `MasterLease`（`status: :active`）
**条件:** 翌月分の OwnerPayment が未作成
**生成内容:**

| カラム | 値 |
|--------|-----|
| master_lease_id | マスターリースID |
| target_month | 翌月1日 |
| guaranteed_amount | ML の保証賃料（`guaranteed_rent`） |
| deduction | 0（デフォルト） |
| net_amount | 保証賃料と同額 |
| status | `:unpaid` |

```ruby
next_month = Date.current.next_month.beginning_of_month
MasterLease.where(status: :active).find_each do |ml|
  next if ml.owner_payments.exists?(target_month: next_month..next_month.end_of_month)
  ml.owner_payments.create!(
    target_month: next_month,
    guaranteed_amount: ml.guaranteed_rent,
    deduction: 0,
    net_amount: ml.guaranteed_rent,
    status: :unpaid
  )
end
```

## 冪等性

- `exists?` チェックで既存レコードがあればスキップ
- 再実行しても二重生成されない

## 実行スケジュール

- 頻度: 月次
- 推奨時刻: 毎月25日 1:05（入金予定生成の直後）

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/monthly_owner_payment_generation_job.rb` | ジョブクラス |
| `spec/jobs/monthly_owner_payment_generation_job_spec.rb` | テスト |
