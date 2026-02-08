# OverdueDetectionJob — 滞納自動検出

## ステータス: 実装済

## 概要

入金期日を過ぎた未入金レコードの status を `overdue` に自動更新する日次バッチ。

## 現状の問題

- `TenantPayment` の status が `unpaid` のまま放置される
- 滞納一覧画面ではクエリ時に `unpaid + due_date < today` で検出しているが、実際の status は変わらない
- ダッシュボードの滞納件数は `status: :overdue` のみカウントするため、ズレが生じる

## 処理内容

**対象:** `TenantPayment`
**条件:** `status: :unpaid` かつ `due_date < Date.current`
**更新:** `status` → `:overdue`

```ruby
TenantPayment.where(status: :unpaid)
             .where("due_date < ?", Date.current)
             .update_all(status: :overdue)
```

## 冪等性

- 対象は `status: :unpaid` のみ → 既に `overdue` に更新済みのレコードは対象外
- 再実行しても二重処理されない

## 影響範囲

- ダッシュボードの滞納件数・滞納額が正確になる
- 滞納一覧の `or` 条件が不要になりクエリがシンプルに
- エイジング分析の精度向上

## 実行スケジュール

- 頻度: 日次
- 推奨時刻: 毎日 0:00

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/jobs/overdue_detection_job.rb` | ジョブクラス |
| `spec/jobs/overdue_detection_job_spec.rb` | テスト |
