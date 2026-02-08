# マスターリース契約（オーナー契約）

## ステータス: 実装済み

## 概要

オーナーと自社間のマスターリース契約を管理する CRUD 画面。
サブリースの根幹となる契約で、保証賃料・免責期間・賃料改定を含む。
契約形態（サブリース/管理委託/自社物件）に応じてフォーム項目が切り替わる。

現行システムの「賃貸管理 > オーナー契約」に相当する。

## データモデル

### MasterLease（マスターリース契約）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| owner_id | references | YES | オーナー |
| building_id | references | YES | 建物 |
| contract_type | string | YES | 契約形態（sublease / management / own） |
| start_date | date | YES | 契約開始日 |
| end_date | date | | 契約終了日 |
| guaranteed_rent | integer | | 保証賃料（月額・サブリース時） |
| management_fee_rate | decimal | | 管理手数料率（%・管理委託時） |
| rent_review_cycle | integer | | 賃料改定周期（月数） |
| status | integer | YES | 状態（enum） |
| notes | text | | 備考 |

### MasterLease status enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | active | 契約中 |
| 1 | scheduled_termination | 解約予定 |
| 2 | terminated | 解約済 |

### MasterLease contract_type enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | sublease | サブリース |
| 1 | management | 管理委託 |
| 2 | own | 自社物件 |

### ExemptionPeriod（免責期間）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| master_lease_id | references | YES | マスターリース契約 |
| room_id | references | | 部屋（null＝建物全体） |
| start_date | date | YES | 免責開始日 |
| end_date | date | YES | 免責終了日 |
| reason | string | | 事由（新築/退去後/大規模修繕 等） |

### RentRevision（賃料改定履歴）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| master_lease_id | references | YES | マスターリース契約 |
| revision_date | date | YES | 改定日 |
| old_rent | integer | YES | 改定前保証賃料 |
| new_rent | integer | YES | 改定後保証賃料 |
| notes | text | | 改定理由・交渉メモ |

## モデル関連

```
Owner 1──N MasterLease N──1 Building
               │
               ├── 1──N ExemptionPeriod
               └── 1──N RentRevision
```

- `Owner has_many :master_leases`
- `Building has_many :master_leases`
- `MasterLease belongs_to :owner, belongs_to :building`
- `MasterLease has_many :exemption_periods, dependent: :destroy`
- `MasterLease has_many :rent_revisions, dependent: :destroy`

## バリデーション

- MasterLease: `owner`, `building`, `contract_type`, `start_date` が必須
- ExemptionPeriod: `master_lease`, `start_date`, `end_date` が必須
- RentRevision: `master_lease`, `revision_date`, `old_rent`, `new_rent` が必須

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /master_leases | 契約一覧 | テーブル形式で全契約を表示 |
| GET /master_leases/:id | 契約詳細 | 契約情報 + 免責期間一覧 + 賃料改定履歴 |
| GET /master_leases/new | 契約登録 | 契約形態に応じてフォーム項目を表示 |
| GET /master_leases/:id/edit | 契約編集 | 既存契約の編集フォーム |

免責期間・賃料改定はマスターリース詳細画面内でインライン管理する。

## 既存画面への変更

- Owner 詳細画面: マスターリース契約一覧を追加
- Building 詳細画面: マスターリース契約情報を表示
- ナビゲーション: 「契約一覧」リンクを追加

## テスト（予定）

- モデルスペック: バリデーション、関連、enum
- リクエストスペック: MasterLease の全 CRUD アクション
- 免責期間・賃料改定の CRUD
