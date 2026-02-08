# 画面実装ロードマップ

## 概要

物件管理 CRUD を起点に、コア業務画面を段階的に実装していく計画。
各ステップは前ステップのモデルに依存するため、順番に進める。

## 実装順序

### Step 1: 物件管理（建物・部屋）CRUD — 完了

- Building / Room の CRUD 画面
- 詳細は `docs/02_plan/building_room_crud_plan.md` を参照

### Step 2: オーナー（支払先）管理

物件のオーナー情報を管理する。契約系画面の前提となるマスタ。

#### データモデル（想定）

| カラム | 型 | 説明 |
|--------|------|------|
| name | string | オーナー名（必須） |
| name_kana | string | オーナー名カナ |
| phone | string | 電話番号 |
| email | string | メールアドレス |
| postal_code | string | 郵便番号 |
| address | string | 住所 |
| bank_name | string | 銀行名 |
| bank_branch | string | 支店名 |
| account_type | string | 口座種別（普通/当座） |
| account_number | string | 口座番号 |
| account_holder | string | 口座名義 |
| notes | text | 備考 |

#### 関連

- Owner `has_many :buildings`
- Building `belongs_to :owner`（owner_id カラム追加）

#### 実装内容

- Owner の scaffold + CRUD 画面（日本語化）
- Building に owner_id を追加するマイグレーション
- Building フォームにオーナー選択セレクトボックスを追加
- Owner 詳細画面に所有建物一覧を表示

### Step 3: エンド契約（入居者契約）

入居者と部屋の契約情報を管理する。賃貸管理のコア業務。

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

**Contract（契約）**

| カラム | 型 | 説明 |
|--------|------|------|
| room | references | 部屋（必須） |
| tenant | references | 入居者（必須） |
| contract_type | string | 契約種別（普通借家/定期借家） |
| start_date | date | 契約開始日（必須） |
| end_date | date | 契約終了日 |
| rent | integer | 月額賃料 |
| management_fee | integer | 管理費 |
| deposit | integer | 敷金 |
| key_money | integer | 礼金 |
| renewal_fee | integer | 更新料 |
| status | integer | 状態（申込/契約中/解約予定/解約済） |
| notes | text | 備考 |

#### 関連

- Tenant `has_many :contracts`
- Contract `belongs_to :room`, `belongs_to :tenant`
- Room `has_many :contracts`
- 契約作成時に Room の status を連動更新（空室→入居中 等）

#### 実装内容

- Tenant / Contract の CRUD 画面
- Room 詳細画面に契約履歴を表示
- 契約ステータス変更時の Room ステータス連動
- Building 詳細画面で各部屋の契約状況を一覧表示

### Step 4: 入金予定・消込

契約から月次の入金予定を生成し、入金消込を行う。PoC 計画「4.6 アプラス結果取り込み・消込」の基盤。

#### データモデル（想定）

**Payment（入金予定/実績）**

| カラム | 型 | 説明 |
|--------|------|------|
| contract | references | 契約（必須） |
| due_date | date | 入金予定日（必須） |
| amount | integer | 予定金額 |
| paid_amount | integer | 入金額 |
| paid_date | date | 入金日 |
| status | integer | 状態（未入金/入金済/一部入金/滞納） |
| payment_method | string | 入金方法（振込/口座振替/現金） |
| notes | text | 備考 |

#### 実装内容

- 契約から入金予定を一括生成する Service クラス
- 入金予定一覧画面（月別フィルタ）
- 入金消込画面（個別消込）
- 滞納一覧の表示

### Step 5: Excel インポート

PoC 計画「4.2 Excel インポート機能」の検証。物件や契約データの一括取込。

#### 実装内容

- roo gem を使用した .xlsx ファイル読み込み
- アップロード → プレビュー → 確定の3ステップ UI
- 行単位のバリデーションエラー表示
- Building / Room の一括インポートを最初の対象とする

## 全体の関連図

```
Owner ─── 1:N ─── Building ─── 1:N ─── Room ─── 1:N ─── Contract ─── 1:N ─── Payment
                                                           │
                                                           N:1
                                                           │
                                                         Tenant
```

## 備考

- 各ステップは TDD（テスト駆動開発）で進める
- Step ごとに PR を作成し、CI 通過を確認してからマージする
- データモデルは実装時に現行システムの調査結果と照合し、必要に応じて調整する
