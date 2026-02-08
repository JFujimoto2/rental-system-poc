# 解約精算

## ステータス: 実装済

## 概要

契約終了時の精算処理を行う機能。日割り賃料計算と敷金返還額計算の2種類の精算に対応する。
既存システムの「エンド解約賃料精算」「エンド解約敷金精算」に相当する。

## 精算種別

### 賃料精算（tenant_rent）
月の途中で解約する場合の日割り賃料を計算する。

| 項目 | 計算方法 |
|------|----------|
| 日割り賃料 | 月額賃料 ÷ 解約月の日数 |
| 日割り日数 | 解約日の日（1日〜末日） |
| 日割り金額 | 日割り賃料 × 日割り日数 |

### 敷金精算（tenant_deposit）
敷金から原状回復費用等を差し引いた返還額を計算する。

| 項目 | 計算方法 |
|------|----------|
| 返還額 | 預かり敷金 − 原状回復費用 − その他控除 |

## データモデル

### Settlement（精算）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| contract_id | references | 転貸借契約（必須） |
| settlement_type | integer | 精算種別（0: tenant_rent, 1: tenant_deposit） |
| termination_date | date | 解約日 |
| daily_rent | integer | 日割り賃料 |
| days_count | integer | 日割り日数 |
| prorated_rent | integer | 日割り金額 |
| deposit_amount | integer | 預かり敷金 |
| restoration_cost | integer | 原状回復費用 |
| other_deductions | integer | その他控除 |
| refund_amount | integer | 返還額 |
| status | integer | 状態（0: draft, 1: confirmed, 2: paid） |
| notes | text | 備考 |

## ステータス

| 状態 | 説明 |
|------|------|
| draft（下書き） | 作成直後、計算内容の確認中 |
| confirmed（確定） | 精算内容が確定 |
| paid（支払済） | 返還金の支払いが完了 |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /settlements | 精算一覧 | 全精算の一覧表示 |
| GET /settlements/:id | 精算詳細 | 精算内容の詳細表示 |
| GET /settlements/new | 精算作成 | 新規精算フォーム |
| GET /settlements/:id/edit | 精算編集 | 精算内容の修正 |

## 契約画面との連携

- 契約詳細画面（`/contracts/:id`）に「精算作成」リンクを追加
- 契約に紐づく精算履歴を一覧表示
- `contract_id` パラメータで契約を自動選択

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208124959_create_settlements.rb` | Settlementテーブル作成 |
| `app/models/settlement.rb` | モデル（enum, バリデーション, 計算メソッド） |
| `app/controllers/settlements_controller.rb` | CRUD + 自動計算 |
| `app/views/settlements/` | index, show, new, edit, _form |
| `app/views/contracts/show.html.erb` | 精算履歴セクション追加 |

## テスト

- モデルスペック: バリデーション・enum・日割り計算・敷金返還計算 (**実装済**)
- リクエストスペック: CRUD・自動計算・契約連携 (**実装済**)
- システムスペック: 賃料精算作成・敷金精算作成・一覧→詳細遷移・契約画面連携 (**実装済**)
