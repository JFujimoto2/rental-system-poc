# ContractExpirationJob — 契約ステータス更新

## ステータス: 未着手

## 概要

解約日（end_date）を過ぎた契約を自動で `terminated` に遷移する日次バッチ。

## 現状の問題

- `scheduled_termination` の契約が end_date を過ぎても手動変更しない限りそのまま残る
- ダッシュボードの退去予定一覧に過去の契約が表示され続ける

## 処理内容

**対象:** `Contract`
**条件:** `status: :scheduled_termination` かつ `end_date < Date.current`
**更新:** `status` → `:terminated`

```ruby
Contract.where(status: :scheduled_termination)
        .where("end_date < ?", Date.current)
        .find_each do |contract|
  contract.update!(status: :terminated)
end
```

## 冪等性

- 対象は `status: :scheduled_termination` のみ → 既に `terminated` のレコードは対象外
- `find_each` で1件ずつ処理し、コールバック（将来追加時）にも対応

## 影響範囲

- ダッシュボードの退去予定一覧が正確になる
- 解約済み契約が「解約予定」として表示され続ける問題を解消

## 実行スケジュール

- 頻度: 日次
- 推奨時刻: 毎日 0:05
- 依存: MasterLeaseExpirationJob の後に実行（ML終了による連鎖を先に処理）

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/contract_expiration_job.rb` | ジョブクラス |
| `spec/jobs/contract_expiration_job_spec.rb` | テスト |
