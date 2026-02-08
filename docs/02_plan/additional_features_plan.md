# 追加機能 実装計画

## 概要

Step 1〜7（物件管理・オーナー・マスターリース・入居者契約・入出金・Excelインポート・認証）の完了後、
既存システム（104画面）でカバーできていない領域のうち、PoC として実装価値が高い機能を追加していく。

既存システムの画面構成は `docs/01_investigation/current_menu_structure.md` を参照。

## 現状カバー率

| 領域 | 既存システム | PoC実装済 | 未実装 |
|------|-------------|-----------|--------|
| 物件管理 | ○ | ○ | — |
| オーナー契約 | 5画面 | CRUD済 | 精算系 |
| エンド契約 | 7画面 | CRUD済 | 精算・募集条件 |
| 入出金処理 | 8画面 | CRUD+一括消込+滞納管理済 | 振替 |
| 経理帳票 | 3画面 | なし | 全部 |
| 承認管理 | 4画面 | なし | 全部 |
| マスタ管理 | 3画面 | なし | 全部 |
| 検索・CSV | — | 全8画面実装済 | — |
| 認証・権限 | — | 実装済 | — |
| Excelインポート | — | 実装済 | — |
| ダッシュボード | — | 実装済 | — |

## 追加機能一覧（実装優先順）

### Step 8: ダッシュボード — 実装済

**対応する既存機能:** トップページ（既存システムにはメニューのみ）
**難易度:** 低　**新規テーブル:** 不要　**工数目安:** 小
**詳細:** `docs/06_features/08_dashboard.md`

#### 概要
ログイン後のトップページに業務KPIを集約表示する。
既存データの集計のみで実現でき、新テーブル不要。

#### 表示項目
| KPI | 計算方法 |
|-----|----------|
| 入居率 | `Room.occupied.count / Room.count` |
| 空室数 | `Room.where(status: :vacant).count` |
| 今月の滞納件数・金額 | `TenantPayment.where(status: :overdue)` の集計 |
| 今月の未入金件数 | `TenantPayment.where(status: :unpaid, due_date: ..today)` |
| オーナー支払未済件数 | `OwnerPayment.where(status: :unpaid)` の当月分 |
| 契約更新予定（3ヶ月以内） | `Contract.where(end_date: today..3.months.from_now, status: :active)` |
| 解約予定 | `Contract.where(status: :scheduled_termination)` |

#### 実装内容
- `DashboardController#index` を新規作成
- `root` ルートをダッシュボードに設定
- グラフ表示は Chart.js or Chartkick（任意）
- レスポンシブなカード型レイアウト

---

### Step 9: 滞納管理 — 実装済

**対応する既存機能:** 滞納情報作成、滞納情報
**難易度:** 中　**新規テーブル:** 0（既存データで実現）　**工数目安:** 中
**詳細:** `docs/06_features/09_delinquency.md`

#### 概要
入金期日を過ぎた未入金・一部入金を自動検出し、滞納一覧として表示する。
日常業務で最も重要な管理機能の一つ。

#### 機能
- 滞納一覧画面（入居者名・物件・部屋・滞納日数・滞納額）
- 滞納日数による色分け（30日/60日/90日超）
- 入居者別の滞納集計
- ステータス自動更新（due_date 超過 + unpaid → overdue）
- （任意）督促履歴テーブル（DelinquencyRecord: tenant_payment_id, action, note, recorded_at）

#### データソース
- `TenantPayment` の既存カラムで実現可能
- `status: [:unpaid, :partial]` かつ `due_date < Date.current` を滞納とみなす

---

### Step 10: 入金一括消込 — 実装済

**対応する既存機能:** 入金取込・一括消込、入金消込
**難易度:** 中　**新規テーブル:** 不要　**工数目安:** 中
**詳細:** `docs/06_features/10_bulk_clearing.md`

#### 概要
銀行の入金明細CSV をアップロードし、入金予定との自動マッチング＋一括消込を行う。
手作業の消込を大幅に効率化する日常業務の中核機能。

#### 機能
- CSVアップロード画面（銀行入金明細）
- 入金予定との自動マッチング（金額・入居者名で照合）
- マッチング結果のプレビュー（一致/不一致/部分一致）
- 一括消込の実行（チェックボックスで選択）
- 消込結果のサマリ表示

#### 処理フロー
```
CSV アップロード
  ↓
パース（振込人名・金額・日付を抽出）
  ↓
入金予定（TenantPayment: unpaid）と照合
  - 金額完全一致 → 自動マッチ
  - 金額不一致 → 手動確認候補
  - マッチなし → 不明入金リスト
  ↓
プレビュー画面で確認
  ↓
一括消込実行（status: paid, paid_amount, paid_date を更新）
```

#### 実装方針
- Step 6（Excel インポート）の3ステップ UI パターンを流用
- Service クラスで照合ロジックを実装
- CSVフォーマットは汎用的に（カラムマッピング設定可能）

---

### Step 11: 解約精算

**対応する既存機能:** エンド解約賃料精算、エンド解約敷金精算、オーナー解約賃料精算、オーナー解約敷金精算
**難易度:** 高　**新規テーブル:** 1（Settlement）　**工数目安:** 大

#### 概要
契約終了時の精算処理。日割り計算、敷金返還、原状回復費用の差し引きを行う。
複雑なビジネスロジックを Rails で実装できる証明になる。

#### データモデル（想定）

**Settlement（精算）**

| カラム | 型 | 説明 |
|--------|------|------|
| contract | references | 転貸借契約（必須） |
| settlement_type | string | 精算種別（tenant_rent: エンド賃料精算 / tenant_deposit: エンド敷金精算） |
| termination_date | date | 解約日 |
| daily_rent | integer | 日割り賃料 |
| days_count | integer | 日割り日数 |
| prorated_rent | integer | 日割り金額 |
| deposit_amount | integer | 預かり敷金 |
| restoration_cost | integer | 原状回復費用 |
| other_deductions | integer | その他控除 |
| refund_amount | integer | 返還額（敷金 - 原状回復 - 控除） |
| status | string | 状態（draft/confirmed/paid） |
| notes | text | 備考 |

#### 機能
- 契約詳細画面から精算作成へ遷移
- 日割り賃料の自動計算（月額賃料 ÷ 月日数 × 残日数）
- 敷金返還額の自動計算（敷金 − 原状回復費 − その他控除）
- 精算書プレビュー
- （任意）精算書PDF出力

---

### Step 12: 帳票・レポート

**対応する既存機能:** 債権滞留表、残高照会、仕訳照会
**難易度:** 中　**新規テーブル:** 不要　**工数目安:** 中

#### 概要
物件別収支サマリ、入金エイジング分析など、経営判断に必要なレポートを提供する。
既存データの集計のみで実現可能。

#### レポート種別

**1. 物件別収支サマリ**
- 建物ごとの月次収支（転貸賃料収入 − 保証賃料支出 − 管理コスト）
- 入居率・空室率の推移
- 対象期間の指定（月次/四半期/年次）

**2. 債権滞留表（エイジング分析）**
- 滞納期間別の分類（〜30日 / 31〜60日 / 61〜90日 / 90日超）
- 入居者別・物件別の集計
- CSV エクスポート対応

**3. 入金実績レポート**
- 月別の入金予定 vs 実績
- 入金率の推移
- 入金方法別の内訳

#### 実装方針
- `ReportsController` を新規作成
- 各レポートは専用のアクション（`property_pl`, `aging`, `payment_summary`）
- 集計ロジックは Service クラスまたはモデルの scope で実装
- HTML 表示 + CSV ダウンロード対応

---

### Step 13: 承認ワークフロー

**対応する既存機能:** 承認受付一覧、承認状況一覧、承認代行委任設定、申請状況一覧
**難易度:** 高　**新規テーブル:** 2（Approval, ApprovalFlow）　**工数目安:** 大

#### 概要
契約の作成・変更・解約に承認フローを導入する。
PoC ではシンプルな1段階承認（申請 → 承認/却下）で実装。

#### データモデル（想定）

**Approval（承認）**

| カラム | 型 | 説明 |
|--------|------|------|
| approvable_type | string | 承認対象のモデル名（polymorphic） |
| approvable_id | integer | 承認対象のID |
| requester | references | 申請者（User） |
| approver | references | 承認者（User、null可） |
| status | string | 状態（pending/approved/rejected） |
| requested_at | datetime | 申請日時 |
| decided_at | datetime | 承認/却下日時 |
| comment | text | 承認者コメント |

#### 機能
- 契約作成時に承認申請を自動生成（operator → manager/admin）
- 承認待ち一覧画面（manager/admin 向け）
- 承認/却下の操作（コメント付き）
- 申請状況一覧（自分の申請の進捗確認）
- 承認完了後にステータスを自動更新

---

## 外部連携（参考・将来対応）

PoC スコープ外だが、本番移行時に必要となる外部連携を参考として記載。

| 優先度 | 連携先 | 機能 | 概要 |
|--------|--------|------|------|
| 高 | アプラス | 口座振替 | 振替依頼CSV出力 → 結果CSV取込 |
| 高 | OBIC7 | 会計仕訳 | 35業務の仕訳ルールに基づくCSV出力（FTP） |
| 中 | GoWeb | 契約データ | エンド契約情報のファイル出力 |
| 低 | 保証会社 | 保証管理 | 保証会社との連携管理 |

## 実装方針

- 各ステップは TDD（Red → Green → Refactor）で進める
- Step ごとにドキュメント（`docs/06_features/`）を作成する
- 既存テストが壊れないことを確認してから次のステップに進む
- `bundle exec rspec` 全通過 + `bin/rubocop` 違反なしを維持する
