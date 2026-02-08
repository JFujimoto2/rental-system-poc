# 入出金管理

## ステータス: 実装済

## 概要

入居者からの入金（転貸賃料）とオーナーへの支払（保証賃料）の両方を管理する CRUD 画面。
サブリース事業の収支を把握するための基盤機能。

現行システムの「賃貸管理 > 入金管理」「賃貸管理 > オーナー支払管理」に相当する。

## データモデル

### TenantPayment（入居者入金）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| contract_id | references | YES | 転貸借契約 |
| due_date | date | YES | 入金予定日 |
| amount | integer | YES | 予定金額 |
| paid_amount | integer | | 入金額 |
| paid_date | date | | 入金日 |
| status | integer | YES | 状態（enum） |
| payment_method | integer | | 入金方法（enum） |
| notes | text | | 備考 |

### TenantPayment status enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | unpaid | 未入金 |
| 1 | paid | 入金済 |
| 2 | partial | 一部入金 |
| 3 | overdue | 滞納 |

### TenantPayment payment_method enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | transfer | 振込 |
| 1 | direct_debit | 口座振替 |
| 2 | cash | 現金 |

### OwnerPayment（オーナー支払）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| master_lease_id | references | YES | マスターリース契約 |
| target_month | date | YES | 対象年月 |
| guaranteed_amount | integer | YES | 保証賃料 |
| deduction | integer | | 控除額（修繕費等） |
| net_amount | integer | YES | 差引支払額 |
| status | integer | YES | 状態（enum） |
| paid_date | date | | 支払日 |
| notes | text | | 備考 |

### OwnerPayment status enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | unpaid | 未払 |
| 1 | paid | 支払済 |

## モデル関連

```
Contract 1──N TenantPayment
MasterLease 1──N OwnerPayment
```

- `Contract has_many :tenant_payments, dependent: :destroy`
- `TenantPayment belongs_to :contract`
- `MasterLease has_many :owner_payments, dependent: :destroy`
- `OwnerPayment belongs_to :master_lease`

## バリデーション

- TenantPayment: `contract`, `due_date`, `amount`, `status` が必須
- OwnerPayment: `master_lease`, `target_month`, `guaranteed_amount`, `net_amount`, `status` が必須

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /tenant_payments | 入金予定一覧 | テーブル形式、月別フィルタ |
| GET /tenant_payments/:id | 入金詳細 | 入金情報の詳細 |
| GET /tenant_payments/new | 入金予定登録 | |
| GET /tenant_payments/:id/edit | 入金編集（消込） | 入金額・入金日・状態を更新 |
| GET /owner_payments | オーナー支払一覧 | テーブル形式、月別フィルタ |
| GET /owner_payments/:id | オーナー支払詳細 | 支払情報の詳細 |
| GET /owner_payments/new | オーナー支払登録 | |
| GET /owner_payments/:id/edit | オーナー支払編集 | 支払処理 |

## 既存画面への変更

- Contract 詳細画面: 入金予定一覧を追加
- MasterLease 詳細画面: オーナー支払一覧を追加
- ナビゲーション: 「入金管理」「オーナー支払」リンクを追加

## テスト

- モデルスペック: バリデーション、関連、enum、ラベルメソッド (**実装済**)
- リクエストスペック: TenantPayment / OwnerPayment の全 CRUD アクション (**実装済**)
- システムスペック: 入金登録・消込・オーナー支払の画面操作 (**実装済**)
