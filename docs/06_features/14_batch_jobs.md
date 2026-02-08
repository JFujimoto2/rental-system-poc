# バッチジョブ（定期実行タスク）

## ステータス: 未着手

## 概要

日次・月次で自動実行すべき定期タスクを Solid Queue ジョブとして実装する。
現状、ステータス更新はすべて手動操作またはクエリ時の判定に依存しており、
データの整合性やダッシュボードの正確性に影響が出る可能性がある。

## 現状の課題

| 課題 | 現状の動作 | あるべき姿 |
|------|----------|-----------|
| 滞納検出 | Delinquencies画面のクエリ時に `unpaid + due_date < today` を判定 | status を `overdue` に実際に更新し、ダッシュボード等でも正確に集計 |
| 契約終了 | 解約日を過ぎても `scheduled_termination` のまま | `end_date` 超過で `terminated` に自動遷移 |
| 部屋ステータス | 契約が終了しても手動で部屋の状態を変更 | 契約終了時に自動で `vacant` に更新 |
| 入金予定生成 | 手動で1件ずつ作成 | 月次で active 契約から翌月分を一括生成 |
| オーナー支払生成 | 手動で1件ずつ作成 | 月次で active な MasterLease から翌月分を一括生成 |
| MLステータス | `end_date` を過ぎても手動変更が必要 | 自動で `terminated` に遷移、配下契約にも連動 |

## ジョブ一覧

### 日次実行（優先度：高）

#### 1. OverdueDetectionJob — 滞納自動検出

入金期日を過ぎた未入金レコードの status を `overdue` に更新する。

**対象:** `TenantPayment`
**条件:** `status: :unpaid` かつ `due_date < Date.current`
**更新:** `status` を `:overdue` に変更

```ruby
# 処理イメージ
TenantPayment.where(status: :unpaid)
             .where("due_date < ?", Date.current)
             .update_all(status: :overdue)
```

**影響範囲:**
- ダッシュボードの滞納件数・滞納額が正確になる
- 滞納一覧の `or` 条件（unpaid + due_date 超過）が不要になり、クエリがシンプルに
- エイジング分析の精度向上

---

#### 2. ContractExpirationJob — 契約ステータス更新

解約日を過ぎた契約を自動で `terminated` に遷移する。

**対象:** `Contract`
**条件:** `status: :scheduled_termination` かつ `end_date < Date.current`
**更新:** `status` を `:terminated` に変更

```ruby
# 処理イメージ
Contract.where(status: :scheduled_termination)
        .where("end_date < ?", Date.current)
        .find_each do |contract|
  contract.update!(status: :terminated)
end
```

**影響範囲:**
- ダッシュボードの退去予定一覧が正確になる
- 解約済み契約が「解約予定」として表示され続ける問題を解消

---

#### 3. RoomStatusSyncJob — 部屋ステータス同期

契約が `terminated` になった部屋で、他に active な契約がなければ `vacant` に更新する。

**対象:** `Room`
**条件:** `status: :occupied` または `:notice` の部屋で、active/scheduled_termination な Contract が0件
**更新:** `status` を `:vacant` に変更

```ruby
# 処理イメージ
Room.where(status: [:occupied, :notice]).find_each do |room|
  active_contracts = room.contracts.where(status: [:active, :scheduled_termination]).count
  room.update!(status: :vacant) if active_contracts.zero?
end
```

**追加:** `scheduled_termination` になった契約の部屋を `notice`（退去予定）に更新

```ruby
Contract.where(status: :scheduled_termination).find_each do |contract|
  contract.room.update!(status: :notice) if contract.room.occupied?
end
```

**影響範囲:**
- 入居率の正確性が向上
- ダッシュボードの空室数・退去予定数が正確になる

---

### 月次実行（優先度：中）

#### 4. MonthlyPaymentGenerationJob — 入金予定自動生成

active な契約から翌月分の TenantPayment を一括生成する。

**対象:** `Contract` → `TenantPayment`
**条件:** `status: :active` かつ翌月分の TenantPayment が未作成
**生成内容:**

| カラム | 値 |
|--------|-----|
| contract_id | 契約ID |
| due_date | 翌月1日（or 契約の支払日） |
| amount | 契約の月額賃料（`rent`） |
| status | `:unpaid` |

```ruby
# 処理イメージ
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

**実行タイミング:** 毎月25日頃（翌月分を事前に生成）

---

#### 5. MonthlyOwnerPaymentGenerationJob — オーナー支払自動生成

active な MasterLease から翌月分の OwnerPayment を一括生成する。

**対象:** `MasterLease` → `OwnerPayment`
**条件:** `status: :active` かつ翌月分の OwnerPayment が未作成
**生成内容:**

| カラム | 値 |
|--------|-----|
| master_lease_id | マスターリースID |
| target_month | 翌月1日 |
| guaranteed_amount | ML の保証賃料（`guaranteed_rent`） |
| deduction | 0（デフォルト） |
| net_amount | 保証賃料と同額（控除なし） |
| status | `:unpaid` |

```ruby
# 処理イメージ
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

**実行タイミング:** 毎月25日頃（入金予定と同時）

---

### 日次実行（優先度：低）

#### 6. MasterLeaseExpirationJob — マスターリースステータス更新

`end_date` を過ぎた MasterLease を `terminated` に遷移し、配下の契約にも連動する。

**対象:** `MasterLease`
**条件:** `status: :active` かつ `end_date < Date.current`（end_date が設定されている場合のみ）
**更新:** `status` を `:terminated` に変更
**連動:** 配下の active な Contract も `terminated` に更新 → Room も `vacant` に更新

```ruby
# 処理イメージ
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

---

## 実行スケジュール

| ジョブ | 頻度 | 推奨実行時刻 | 優先度 |
|--------|------|-------------|--------|
| OverdueDetectionJob | 日次 | 毎日 0:00 | 高 |
| ContractExpirationJob | 日次 | 毎日 0:05 | 高 |
| RoomStatusSyncJob | 日次 | 毎日 0:10（↑の後に実行） | 高 |
| MasterLeaseExpirationJob | 日次 | 毎日 0:15 | 低 |
| MonthlyPaymentGenerationJob | 月次 | 毎月25日 1:00 | 中 |
| MonthlyOwnerPaymentGenerationJob | 月次 | 毎月25日 1:05 | 中 |

**依存順序:**
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
- `recurring.yml` で定期実行スケジュールを定義
- ジョブの冪等性を担保（再実行しても二重処理されない設計）
- 更新件数をログ出力（運用監視用）
- TDD で実装（ジョブスペック → 実装）

## 実装ファイル（予定）

| ファイル | 内容 |
|---------|------|
| `app/jobs/overdue_detection_job.rb` | 滞納自動検出 |
| `app/jobs/contract_expiration_job.rb` | 契約ステータス更新 |
| `app/jobs/room_status_sync_job.rb` | 部屋ステータス同期 |
| `app/jobs/master_lease_expiration_job.rb` | MLステータス更新 |
| `app/jobs/monthly_payment_generation_job.rb` | 入金予定自動生成 |
| `app/jobs/monthly_owner_payment_generation_job.rb` | オーナー支払自動生成 |
| `config/recurring.yml` | Solid Queue 定期実行スケジュール |
| `spec/jobs/*.rb` | 各ジョブのテスト |
