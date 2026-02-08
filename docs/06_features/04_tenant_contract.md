# 入居者・転貸借契約（エンド契約）

## ステータス: 実装済み

## 概要

入居者（テナント）の情報管理と、部屋の転貸借契約（エンド契約）を管理する CRUD 画面。
サブリース時は自社が貸主となり入居者と転貸借契約を締結する。
管理委託時はオーナーと入居者の直接契約を代行管理する。

現行システムの「賃貸管理 > 入居者管理」「賃貸管理 > 契約管理」に相当する。

## データモデル

### Tenant（入居者）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| name | string | YES | 入居者名 |
| name_kana | string | | 入居者名カナ |
| phone | string | | 電話番号 |
| email | string | | メールアドレス |
| postal_code | string | | 郵便番号 |
| address | string | | 現住所 |
| emergency_contact | string | | 緊急連絡先 |
| notes | text | | 備考 |

### Contract（転貸借契約/エンド契約）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| room_id | references | YES | 部屋 |
| tenant_id | references | YES | 入居者 |
| master_lease_id | references | | マスターリース契約（紐づけ、optional） |
| lease_type | integer | YES | 借家種別（enum） |
| start_date | date | YES | 契約開始日 |
| end_date | date | | 契約終了日 |
| rent | integer | | 月額賃料（転貸賃料） |
| management_fee | integer | | 管理費（共益費） |
| deposit | integer | | 敷金 |
| key_money | integer | | 礼金 |
| renewal_fee | integer | | 更新料 |
| status | integer | YES | 状態（enum） |
| notes | text | | 備考 |

### Contract lease_type enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | ordinary | 普通借家 |
| 1 | fixed_term | 定期借家 |

### Contract status enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | applying | 申込 |
| 1 | active | 契約中 |
| 2 | scheduled_termination | 解約予定 |
| 3 | terminated | 解約済 |

## モデル関連

```
Tenant 1──N Contract N──1 Room
                │
                N──1 MasterLease（optional）
```

- `Tenant has_many :contracts`
- `Contract belongs_to :room, belongs_to :tenant`
- `Contract belongs_to :master_lease, optional: true`
- `Room has_many :contracts`
- `MasterLease has_many :contracts`

## バリデーション

- Tenant: `name` が必須
- Contract: `room`, `tenant`, `lease_type`, `start_date`, `status` が必須

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /tenants | 入居者一覧 | テーブル形式で全入居者を表示 |
| GET /tenants/:id | 入居者詳細 | 入居者情報 + 契約一覧 |
| GET /tenants/new | 入居者登録 | |
| GET /tenants/:id/edit | 入居者編集 | |
| GET /contracts | 契約一覧 | テーブル形式で全契約を表示 |
| GET /contracts/:id | 契約詳細 | 契約情報の詳細 |
| GET /contracts/new | 契約登録 | 部屋・入居者・マスターリースをセレクト |
| GET /contracts/:id/edit | 契約編集 | |

## 既存画面への変更

- Room 詳細画面: 契約一覧を追加
- Building 詳細画面: 各部屋の契約状況を表示（既存の部屋一覧に入居者名を追加）
- ナビゲーション: 「入居者一覧」「契約一覧」リンクを追加

## テスト（予定）

- モデルスペック: バリデーション、関連、enum
- リクエストスペック: Tenant / Contract の全 CRUD アクション
