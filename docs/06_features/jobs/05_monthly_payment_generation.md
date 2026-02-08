# MonthlyPaymentGenerationJob — 入金予定自動生成

## ステータス: 実装済

## 概要

active な契約から翌月分の TenantPayment を一括生成する月次バッチ。

## 現状の問題

- 入金予定（TenantPayment）を手動で1件ずつ作成している
- 毎月の定型作業で、契約数が増えるほど負担が大きくなる

## 処理内容

**対象:** `Contract`（`status: :active`）
**条件:** 翌月分の TenantPayment が未作成
**生成内容:**

| カラム | 値 |
|--------|-----|
| contract_id | 契約ID |
| due_date | 翌月1日 |
| amount | 契約の月額賃料（`rent`） |
| status | `:unpaid` |

```ruby
next_month = Date.current.next_month.beginning_of_month
Contract.where(status: :active).find_each do |contract|
  next if contract.tenant_payments.exists?(due_date: next_month..next_month.end_of_month)
  contract.tenant_payments.create!(
    due_date: next_month,
    amount: contract.rent,
    status: :unpaid
  )
end
```

## 冪等性

- `exists?` チェックで既存レコードがあればスキップ
- 再実行しても二重生成されない

## 実行スケジュール

- 頻度: 月次
- 推奨時刻: 毎月25日 1:00（翌月分を事前に生成）

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/monthly_payment_generation_job.rb` | ジョブクラス |
| `spec/jobs/monthly_payment_generation_job_spec.rb` | テスト |
