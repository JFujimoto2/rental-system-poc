# 画面実装ロードマップ

## 概要

物件管理 CRUD を起点に、コア業務画面を段階的に実装していく計画。
各ステップは前ステップのモデルに依存するため、順番に進める。

サブリースの二重契約構造（マスターリース＋転貸借）を中心に設計しつつ、
管理委託・自社物件など他の契約形態にも対応できる構造とする。

## 実装順序

### Step 1: 物件管理（建物・部屋）CRUD — 完了

- Building / Room の CRUD 画面
- 詳細は `docs/06_features/01_building_room.md` を参照

### Step 2: オーナー（支払先）管理 — 完了

- Owner の CRUD 画面（基本情報・口座情報）
- Building との紐づけ
- 詳細は `docs/06_features/02_owner.md` を参照

### Step 3: マスターリース契約（オーナー契約） — 完了

オーナーと自社間のマスターリース契約を管理する。
サブリースの根幹となる契約で、保証賃料・免責期間・賃料改定を含む。
詳細は `docs/06_features/03_master_lease.md` を参照

#### データモデル（想定）

**MasterLease（マスターリース契約）**

| カラム | 型 | 説明 |
|--------|------|------|
| owner | references | オーナー（必須） |
| building | references | 建物（必須） |
| contract_type | string | 契約形態（sublease: サブリース / management: 管理委託 / own: 自社物件） |
| start_date | date | 契約開始日（必須） |
| end_date | date | 契約終了日 |
| guaranteed_rent | integer | 保証賃料（月額・サブリース時） |
| management_fee_rate | decimal | 管理手数料率（管理委託時、例: 5%） |
| rent_review_cycle | integer | 賃料改定周期（月数、例: 24） |
| status | integer | 状態（契約中/解約予定/解約済） |
| notes | text | 備考 |

**ExemptionPeriod（免責期間）**

| カラム | 型 | 説明 |
|--------|------|------|
| master_lease | references | マスターリース契約（必須） |
| room | references | 部屋（null可、建物全体の場合はnull） |
| start_date | date | 免責開始日（必須） |
| end_date | date | 免責終了日（必須） |
| reason | string | 事由（新築/退去後/大規模修繕 等） |

**RentRevision（賃料改定履歴）**

| カラム | 型 | 説明 |
|--------|------|------|
| master_lease | references | マスターリース契約（必須） |
| revision_date | date | 改定日（必須） |
| old_rent | integer | 改定前保証賃料 |
| new_rent | integer | 改定後保証賃料 |
| notes | text | 改定理由・交渉メモ |

#### 関連

- Owner `has_many :master_leases`
- Building `has_many :master_leases`
- MasterLease `belongs_to :owner`, `belongs_to :building`
- MasterLease `has_many :exemption_periods`, `has_many :rent_revisions`

#### 実装内容

- MasterLease の CRUD 画面
- 契約形態（サブリース/管理委託/自社物件）の選択に応じてフォーム項目を切り替え
- Owner 詳細画面にマスターリース契約一覧を表示
- Building 詳細画面に契約情報を表示
- 免責期間・賃料改定履歴の管理画面（マスターリース詳細内に組み込み）

### Step 4: 入居者・転貸借契約（エンド契約） — 完了

入居者と部屋の転貸借契約を管理する。サブリース時は自社が貸主となる。
詳細は `docs/06_features/04_tenant_contract.md` を参照

#### データモデル（想定）

**Tenant（入居者）**

| カラム | 型 | 説明 |
|--------|------|------|
| name | string | 入居者名（必須） |
| name_kana | string | 入居者名カナ |
| phone | string | 電話番号 |
| email | string | メールアドレス |
| postal_code | string | 郵便番号 |
| address | string | 現住所 |
| emergency_contact | string | 緊急連絡先 |
| notes | text | 備考 |

**Contract（転貸借契約/エンド契約）**

| カラム | 型 | 説明 |
|--------|------|------|
| room | references | 部屋（必須） |
| tenant | references | 入居者（必須） |
| master_lease | references | マスターリース契約（紐づけ） |
| lease_type | string | 借家種別（ordinary: 普通借家 / fixed_term: 定期借家） |
| start_date | date | 契約開始日（必須） |
| end_date | date | 契約終了日 |
| rent | integer | 月額賃料（転貸賃料） |
| management_fee | integer | 管理費（共益費） |
| deposit | integer | 敷金 |
| key_money | integer | 礼金 |
| renewal_fee | integer | 更新料 |
| status | integer | 状態（申込/契約中/解約予定/解約済） |
| notes | text | 備考 |

#### 関連

- Tenant `has_many :contracts`
- Contract `belongs_to :room`, `belongs_to :tenant`, `belongs_to :master_lease`（optional）
- Room `has_many :contracts`
- MasterLease `has_many :contracts`（1つのマスターリースに対し、複数部屋の転貸借契約が紐づく）
- 契約作成時に Room の status を連動更新（空室→入居中 等）

#### 実装内容

- Tenant の CRUD 画面
- Contract の CRUD 画面（マスターリース契約との紐づけ選択）
- Room 詳細画面に契約履歴を表示
- 契約ステータス変更時の Room ステータス連動
- Building 詳細画面で各部屋の契約状況を一覧表示

### Step 5: 入出金管理 — 完了

入居者からの入金（転貸賃料）とオーナーへの支払（保証賃料）の両方を管理する。

#### データモデル（想定）

**TenantPayment（入居者入金）**

| カラム | 型 | 説明 |
|--------|------|------|
| contract | references | 転貸借契約（必須） |
| due_date | date | 入金予定日（必須） |
| amount | integer | 予定金額 |
| paid_amount | integer | 入金額 |
| paid_date | date | 入金日 |
| status | integer | 状態（未入金/入金済/一部入金/滞納） |
| payment_method | string | 入金方法（振込/口座振替/現金） |
| notes | text | 備考 |

**OwnerPayment（オーナー支払）**

| カラム | 型 | 説明 |
|--------|------|------|
| master_lease | references | マスターリース契約（必須） |
| target_month | date | 対象年月（必須） |
| guaranteed_amount | integer | 保証賃料 |
| deduction | integer | 控除額（修繕費等） |
| net_amount | integer | 差引支払額 |
| status | integer | 状態（未払/支払済） |
| paid_date | date | 支払日 |
| notes | text | 備考 |

#### 実装内容

- 転貸借契約から入金予定を一括生成する Service クラス
- マスターリース契約からオーナー支払予定を一括生成する Service クラス
- 入金予定一覧画面（月別フィルタ）
- 入金消込画面（個別消込）
- オーナー支払一覧・支払処理画面
- 滞納一覧の表示
- 物件単位の収支サマリ（転貸収入 − 保証賃料 − 管理コスト）

### Step 6: Excel インポート — 完了

PoC 計画「4.2 Excel インポート機能」の検証。物件や契約データの一括取込。

#### 実装内容

- roo gem を使用した .xlsx ファイル読み込み
- アップロード → プレビュー → 確定の3ステップ UI
- 行単位のバリデーションエラー表示
- Building / Room の一括インポートを最初の対象とする

### Step 7: 認証・権限管理 — 完了

Microsoft Entra ID / Google OAuth2 による SSO ログインと4ロール権限管理。
詳細は `docs/06_features/07_authentication.md` を参照

### Step 7.5: 検索・CSVダウンロード — 完了

全8画面の一覧ページに検索フォームとCSVダウンロード機能を追加。
各モデルに `self.search` メソッドを実装（ILIKE/FK/enum/joins/日付範囲対応）。
BOM付きUTF-8のCSV出力（Excel対応）。

---

## 追加機能（Step 8〜13）

詳細は `docs/02_plan/additional_features_plan.md` を参照。

### Step 8: ダッシュボード — 完了

ログイン後トップページに業務KPIを集約表示。新テーブル不要。
詳細は `docs/06_features/08_dashboard.md` を参照

### Step 9: 滞納管理 — 完了

入金期日超過の自動検出・滞納一覧・エイジング分類・CSV出力。
詳細は `docs/06_features/09_delinquency.md` を参照

### Step 10: 入金一括消込 — 完了

銀行入金明細CSVから入金予定への自動マッチング＋一括消込。
詳細は `docs/06_features/10_bulk_clearing.md` を参照

### Step 11: 解約精算 — 未着手
日割り計算・敷金返還・原状回復費用の精算処理。

### Step 12: 帳票・レポート — 未着手
物件別収支サマリ・債権滞留表・入金実績レポート。

### Step 13: 承認ワークフロー — 未着手
契約の作成・変更に対するシンプルな1段階承認フロー。

## 全体の関連図

```
                    ┌── ExemptionPeriod
                    │
Owner 1──N MasterLease 1──N RentRevision
                │
                │ N──1 Building 1──N Room
                │                    │
                │                    1──N Contract 1──N TenantPayment
                │                           │
                1──N OwnerPayment            N──1 Tenant
                    （保証賃料支払）            （入居者）
```

### 契約形態別の構造

**サブリースの場合:**
```
Owner ──[MasterLease]──> 自社 ──[Contract]──> Tenant
        保証賃料              転貸賃料
```

**管理委託の場合:**
```
Owner ──[MasterLease(management)]──> 自社（管理受託）
Room ──[Contract]──> Tenant（オーナーと入居者の直接契約を代行管理）
```

**自社物件の場合:**
```
自社所有（Owner不要） ──[MasterLease(own)]──> Room ──[Contract]──> Tenant
```

## 備考

- 各ステップは TDD（テスト駆動開発）で進める
- Step ごとに PR を作成し、CI 通過を確認してからマージする
- データモデルは実装時に現行システムの調査結果と照合し、必要に応じて調整する
- サブリースの業務詳細は `docs/01_investigation/sublease_business_overview.md` を参照
