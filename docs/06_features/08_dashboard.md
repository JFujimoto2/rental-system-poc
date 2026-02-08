# ダッシュボード

## ステータス: 実装済

## 概要

ログイン後のトップページに業務 KPI を集約表示するダッシュボード。
既存データの集計のみで実現しており、新規テーブルは不要。

従来は `root` が建物一覧（`buildings#index`）を指していたが、
ダッシュボード（`dashboard#index`）に変更した。

## 表示項目

### 入居状況カード

| KPI | 計算方法 |
|-----|----------|
| 入居率 | `Room.occupied.count / Room.count * 100` |
| 総部屋数 | `Room.count` |
| 入居中 | `Room.occupied.count` |
| 退去予定 | `Room.notice.count` |
| 空室 | `Room.vacant.count` |

### 滞納状況カード

| KPI | 計算方法 |
|-----|----------|
| 滞納件数 | `TenantPayment.where(status: :overdue).count` |
| 滞納額合計 | `TenantPayment.where(status: :overdue).sum(:amount)` |
| 期日超過未入金 | `TenantPayment.where(status: :unpaid).where("due_date <= ?", today).count` |

### オーナー支払カード

| KPI | 計算方法 |
|-----|----------|
| 未払件数 | `OwnerPayment.where(status: :unpaid).count` |

### 契約更新予定（3ヶ月以内）

契約終了日が今日から3ヶ月以内の `active` な契約を一覧表示。
建物名・部屋番号・入居者名・契約終了日・残日数を表示。

### 解約予定

`scheduled_termination` ステータスの契約を一覧表示。
建物名・部屋番号・入居者名・契約終了日を表示。

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET / | ダッシュボード | KPI カード + 契約一覧テーブル |

## ルーティング変更

```ruby
# 変更前
root "buildings#index"

# 変更後
root "dashboard#index"
```

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/controllers/dashboard_controller.rb` | KPI 集計ロジック |
| `app/views/dashboard/index.html.erb` | ダッシュボードビュー |
| `app/assets/stylesheets/application.css` | ダッシュボード用 CSS |

## テスト

- リクエストスペック: ダッシュボード表示・KPI 項目の存在確認・データ有り時の集計 (**実装済**)
