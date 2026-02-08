# ContractRenewalReminderJob — 契約更新リマインダー自動生成

## ステータス: 実装済

## 概要

契約終了日が3ヶ月以内に迫っている active 契約に対し、まだ ContractRenewal が
存在しない場合に `pending` ステータスで自動生成する月次バッチ。

## 処理内容

**対象:** `Contract`
**条件:**
- `status: :active`
- `end_date <= 3.months.from_now`
- まだ ContractRenewal レコードが紐付いていない

**処理:**

```ruby
Contract.where(status: :active)
        .where("end_date <= ?", 3.months.from_now.to_date)
        .where.not(id: ContractRenewal.select(:contract_id))
        .find_each do |contract|
  ContractRenewal.create!(
    contract: contract,
    status: :pending,
    current_rent: contract.rent
  )
end
```

## 冪等性

- `where.not(id: ContractRenewal.select(:contract_id))` により、既に ContractRenewal が存在する契約はスキップ
- 再実行しても二重生成されない

## 実行スケジュール

- 頻度: 月次
- 推奨時刻: 毎月1日 0:20

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/contract_renewal_reminder_job.rb` | ジョブクラス |
| `spec/jobs/contract_renewal_reminder_job_spec.rb` | テスト |
