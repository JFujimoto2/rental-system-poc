# 業者マスタ + 工事管理

## ステータス: 実装済

## 概要

原状回復・修繕・設備交換などの工事を管理する機能。業者マスタで取引先を一元管理し、
工事レコードで部屋単位の工事進捗・費用を追跡する。承認ワークフローとも連携可能。

## 業務フロー

```
退去 → 原状回復工事発注 → 施工 → 完了 → 請求 → 精算
         ↑                              ↑
    業者マスタから選択           Settlement.restoration_cost と連動
```

## データモデル

### Vendor（業者）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| name | string | 業者名（必須） |
| phone | string | 電話番号 |
| email | string | メールアドレス |
| address | string | 住所 |
| contact_person | string | 担当者名 |
| notes | text | 備考 |

### Construction（工事）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| room_id | references | 部屋（必須） |
| vendor_id | references | 業者（任意） |
| construction_type | integer | 工事種別 enum |
| status | integer | 状態 enum |
| title | string | 工事件名（必須） |
| description | text | 工事内容 |
| estimated_cost | integer | 見積金額 |
| actual_cost | integer | 実績金額 |
| scheduled_start_date | date | 工事予定開始日 |
| scheduled_end_date | date | 工事予定完了日 |
| actual_start_date | date | 実績開始日 |
| actual_end_date | date | 実績完了日 |
| cost_bearer | integer | 費用負担 enum |
| notes | text | 備考 |

## enum 定義

### construction_type（工事種別）

| 値 | 日本語 |
|----|--------|
| restoration | 原状回復 |
| renovation | リノベーション |
| repair | 修繕 |
| equipment | 設備交換 |
| other | その他 |

### status（状態）

| 値 | 日本語 | 説明 |
|----|--------|------|
| draft | 下書き | 工事内容の検討中 |
| ordered | 発注済 | 業者に発注した状態 |
| in_progress | 施工中 | 工事が進行中 |
| completed | 完了 | 工事完了 |
| invoiced | 請求済 | 業者から請求を受領 |
| cancelled | キャンセル | 工事中止 |

### cost_bearer（費用負担）

| 値 | 日本語 |
|----|--------|
| company | 自社負担 |
| owner | オーナー負担 |
| tenant | 入居者負担 |

## 承認ワークフロー連携

Construction は polymorphic 承認（`has_many :approvals, as: :approvable`）に対応。
承認実行時、`activate_approvable!` により status が `ordered` に自動更新される。

## 画面一覧

### 業者（Vendor）

| パス | 画面 | 説明 |
|------|------|------|
| GET /vendors | 業者一覧 | 検索（業者名・電話番号）+ CSV |
| GET /vendors/:id | 業者詳細 | 業者情報の表示 |
| GET /vendors/new | 業者登録 | 新規業者フォーム |
| GET /vendors/:id/edit | 業者編集 | 業者情報の修正 |

### 工事（Construction）

| パス | 画面 | 説明 |
|------|------|------|
| GET /constructions | 工事一覧 | 検索（建物名・業者名・種別・状態・費用負担）+ CSV |
| GET /constructions/:id | 工事詳細 | 工事情報の表示 |
| GET /constructions/new | 工事登録 | 新規工事フォーム |
| GET /constructions/:id/edit | 工事編集 | 工事情報の修正 |

## 部屋画面との連携

- 部屋詳細画面（`/rooms/:id`）に「工事履歴」セクションを追加
- 工事件名・種別・業者名・見積/実績金額・状態を一覧表示
- 「この部屋に工事を追加」リンクで `room_id` を自動セット

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208140657_create_vendors.rb` | Vendorテーブル作成 |
| `db/migrate/20260208140702_create_constructions.rb` | Constructionテーブル作成 |
| `app/models/vendor.rb` | モデル（バリデーション, search） |
| `app/models/construction.rb` | モデル（enum, バリデーション, search, 承認連携） |
| `app/controllers/vendors_controller.rb` | CRUD + 検索 + CSV |
| `app/controllers/constructions_controller.rb` | CRUD + 検索 + CSV |
| `app/views/vendors/` | index, show, new, edit, _form |
| `app/views/constructions/` | index, show, new, edit, _form |
| `app/views/rooms/show.html.erb` | 工事履歴セクション追加 |
| `app/models/approval.rb` | `activate_approvable!` に Construction 対応追加 |
| `app/helpers/application_helper.rb` | `approvable_summary` に Construction 追加 |

## テスト

- モデルスペック: Vendor（association, validation, search）+ Construction（association, validation, enum, search, label）(**実装済**)
- リクエストスペック: Vendor CRUD/CSV + Construction CRUD/CSV (**実装済**)
- システムスペック: Vendor CRUD + Construction CRUD + 部屋画面連携 (**実装済**)
