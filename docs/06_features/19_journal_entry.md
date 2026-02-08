# 会計仕訳（勘定科目・仕訳・仕訳明細）

## ステータス: 未実装

## 概要

サブリース賃貸管理における会計仕訳機能。標準的な勘定科目体系で仕訳を管理し、
OBIC7 会計システムへの連携基盤として汎用 CSV エクスポートを提供する。
テナント入金・オーナー支払・敷金・礼金・修繕・更新料・保険料の9パターンの
仕訳を自動生成する。

## 業務フロー

```
テナント入金(paid) → 仕訳自動生成（借方: 普通預金 / 貸方: 転貸賃料収入）
オーナー支払(paid) → 仕訳自動生成（借方: 支払家賃 / 貸方: 普通預金）
契約(deposit>0)    → 仕訳自動生成（借方: 普通預金 / 貸方: 預り敷金）
解約精算           → 仕訳自動生成（借方: 預り敷金 / 貸方: 普通預金）
工事(completed)    → 仕訳自動生成（借方: 修繕費 / 貸方: 未払金）
契約更新(fee>0)    → 仕訳自動生成（借方: 普通預金 / 貸方: 更新料収入）
保険(premium>0)    → 仕訳自動生成（借方: 保険料 / 貸方: 普通預金）

仕訳一覧 → 承認 → CSV エクスポート（OBIC7 連携用）
```

## 設計判断

| 項目 | 決定 | 理由 |
|------|------|------|
| 仕訳テンプレート | サービスクラス（JournalEntryGenerator）で実装 | PoC では十分。OBIC7 コード判明時はサービス1ファイルの修正で対応可能 |
| 仕訳の生成タイミング | コントローラから手動一括生成（generate アクション） | 既存コントローラへの変更を最小化 |
| 勘定科目 | 12科目の標準体系 | サブリース業務に必要な最小セット |
| OBIC7 CSV | プレースホルダ形式で実装 | 仕訳日/借方/貸方/金額/摘要 の汎用フォーマット |
| 会計年度 | 4月始まり（日本標準） | entry_date から自動計算 |

## データモデル

### AccountTitle（勘定科目マスタ）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| code | string | 科目コード（一意、例: "111"） |
| name | string | 科目名（例: "普通預金"） |
| account_category | integer | 科目区分 enum |

### JournalEntry（仕訳）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| entry_date | date | 仕訳日（必須） |
| description | string | 摘要 |
| journalizable_type | string | 取引元モデル名（polymorphic） |
| journalizable_id | bigint | 取引元 ID |
| fiscal_year | integer | 会計年度（自動計算: 4月始まり） |
| status | integer | ステータス enum |
| total_amount | integer | 金額 |
| notes | text | 備考 |

### JournalEntryLine（仕訳明細）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| journal_entry_id | references | 仕訳（必須） |
| account_title_id | references | 勘定科目（必須） |
| side | integer | 貸借区分 enum |
| amount | integer | 金額 |

## enum 定義

### account_category（科目区分）

| 値 | 日本語 |
|----|--------|
| asset | 資産 |
| liability | 負債 |
| equity | 純資産 |
| revenue | 収益 |
| expense | 費用 |

### status（仕訳ステータス）

| 値 | 日本語 | 説明 |
|----|--------|------|
| draft | 下書き | 作成直後の状態 |
| approved | 承認済 | 承認された仕訳 |
| exported | エクスポート済 | CSV 出力済み |

### side（貸借区分）

| 値 | 日本語 |
|----|--------|
| debit | 借方 |
| credit | 貸方 |

## 勘定科目マスタ（初期データ 12科目）

| Code | Name | Category |
|------|------|----------|
| 111 | 普通預金 | asset |
| 131 | 未収入金 | asset |
| 211 | 未払金 | liability |
| 212 | 預り敷金 | liability |
| 311 | 資本金 | equity |
| 411 | 転貸賃料収入 | revenue |
| 412 | 管理費収入 | revenue |
| 413 | 更新料収入 | revenue |
| 414 | 礼金収入 | revenue |
| 511 | 支払家賃 | expense |
| 512 | 修繕費 | expense |
| 513 | 保険料 | expense |

## 仕訳パターン（JournalEntryGenerator が生成）

| # | 取引 | 借方 | 貸方 | 発生元 |
|---|------|------|------|--------|
| 1 | テナント入金（賃料） | 普通預金(111) | 転貸賃料収入(411) | TenantPayment(paid) |
| 2 | テナント入金（管理費あり） | 普通預金(111) | 転貸賃料収入(411) + 管理費収入(412) | TenantPayment(paid) |
| 3 | オーナー支払 | 支払家賃(511) | 普通預金(111) | OwnerPayment(paid) |
| 4 | 敷金預かり | 普通預金(111) | 預り敷金(212) | Contract(deposit > 0) |
| 5 | 礼金収入 | 普通預金(111) | 礼金収入(414) | Contract(key_money > 0) |
| 6 | 敷金返還 | 預り敷金(212) | 普通預金(111) | Settlement(tenant_deposit) |
| 7 | 原状回復・修繕 | 修繕費(512) | 未払金(211) | Construction(completed) |
| 8 | 更新料収入 | 普通預金(111) | 更新料収入(413) | ContractRenewal(renewal_fee > 0) |
| 9 | 保険料支払 | 保険料(513) | 普通預金(111) | Insurance(premium > 0) |

## Polymorphic 関連（journalizable）

以下の7モデルに `has_many :journal_entries, as: :journalizable` を追加:

- TenantPayment
- OwnerPayment
- Contract
- Settlement
- Construction
- ContractRenewal
- Insurance

## バリデーション

### AccountTitle
- `code`: 必須、一意
- `name`: 必須
- `account_category`: 必須

### JournalEntry
- `entry_date`: 必須
- `fiscal_year`: 自動計算（4月始まり: 1〜3月は前年度）
- 借方合計 = 貸方合計（貸借一致）

### JournalEntryLine
- `journal_entry`: 必須
- `account_title`: 必須
- `side`: 必須
- `amount`: 必須、0以上

## 画面一覧

### 勘定科目（AccountTitle）

| パス | 画面 | 説明 |
|------|------|------|
| GET /account_titles | 勘定科目一覧 | 検索（科目コード・科目名・科目区分）+ CSV |
| GET /account_titles/:id | 勘定科目詳細 | 勘定科目情報の表示 |
| GET /account_titles/new | 勘定科目登録 | 新規勘定科目フォーム |
| GET /account_titles/:id/edit | 勘定科目編集 | 勘定科目情報の修正 |

### 仕訳（JournalEntry）

| パス | 画面 | 説明 |
|------|------|------|
| GET /journal_entries | 仕訳一覧 | 検索（仕訳日・摘要・ステータス・会計年度）+ CSV |
| GET /journal_entries/:id | 仕訳詳細 | 仕訳情報 + 明細の表示 |
| GET /journal_entries/new | 仕訳登録 | 新規仕訳フォーム（明細行の動的追加） |
| GET /journal_entries/:id/edit | 仕訳編集 | 仕訳情報の修正 |
| POST /journal_entries/generate | 仕訳一括生成 | 未生成の取引から仕訳を自動生成 |

## サービスクラス

### JournalEntryGenerator

仕訳の一括自動生成を担当するサービスクラス。

**責務:**
- 未生成の取引（TenantPayment, OwnerPayment, Contract, Settlement, Construction, ContractRenewal, Insurance）を検出
- 仕訳パターンに従い JournalEntry + JournalEntryLine を生成
- 冪等性を保証（同一取引に対して二重生成しない）

**インターフェース:**
```ruby
generator = JournalEntryGenerator.new
result = generator.generate_all
# => { generated: 15, skipped: 3, errors: [] }
```

## バッチジョブ

### JournalExportJob

承認済み仕訳の CSV エクスポートジョブ。

**処理内容:**
1. `approved` ステータスの仕訳を取得
2. OBIC7 プレースホルダ形式の CSV を生成
3. ステータスを `exported` に更新

**CSV フォーマット（OBIC7 プレースホルダ）:**

| カラム | 説明 |
|--------|------|
| 仕訳日 | entry_date（YYYY-MM-DD） |
| 借方科目コード | debit 側の account_title.code |
| 借方科目名 | debit 側の account_title.name |
| 貸方科目コード | credit 側の account_title.code |
| 貸方科目名 | credit 側の account_title.name |
| 金額 | total_amount |
| 摘要 | description |

詳細は `docs/06_features/jobs/10_journal_export.md` を参照。

## 実装ファイル（予定）

| ファイル | 内容 |
|---------|------|
| `db/migrate/xxx_create_account_titles.rb` | AccountTitle テーブル作成 |
| `db/migrate/xxx_create_journal_entries.rb` | JournalEntry テーブル作成 |
| `db/migrate/xxx_create_journal_entry_lines.rb` | JournalEntryLine テーブル作成 |
| `app/models/account_title.rb` | モデル（enum, バリデーション, search） |
| `app/models/journal_entry.rb` | モデル（enum, バリデーション, polymorphic, 貸借一致バリデーション） |
| `app/models/journal_entry_line.rb` | モデル（enum, バリデーション） |
| `app/services/journal_entry_generator.rb` | 仕訳自動生成サービス（9パターン） |
| `app/controllers/account_titles_controller.rb` | CRUD + 検索 + CSV |
| `app/controllers/journal_entries_controller.rb` | CRUD + 検索 + CSV + generate |
| `app/views/account_titles/` | index, show, new, edit, _form |
| `app/views/journal_entries/` | index, show, new, edit, _form |
| `app/jobs/journal_export_job.rb` | CSV エクスポートジョブ |

## 既存ファイル修正（予定）

| ファイル | 変更内容 |
|---------|---------|
| `config/routes.rb` | `resources :account_titles, :journal_entries` + generate アクション |
| `config/locales/ja.yml` | 3モデル分の i18n |
| `db/seeds.rb` | 勘定科目12件 + 仕訳サンプル |
| `app/views/layouts/application.html.erb` | ナビに「会計」グループ追加 |
| `app/models/tenant_payment.rb` | `has_many :journal_entries, as: :journalizable` |
| `app/models/owner_payment.rb` | 同上 |
| `app/models/contract.rb` | 同上 |
| `app/models/settlement.rb` | 同上 |
| `app/models/construction.rb` | 同上 |
| `app/models/contract_renewal.rb` | 同上 |
| `app/models/insurance.rb` | 同上 |

## テスト（予定）

- モデルスペック: AccountTitle（validation, enum, search）+ JournalEntry（association, validation, enum, 貸借一致）+ JournalEntryLine（association, validation, enum）
- サービススペック: JournalEntryGenerator（9パターン全テスト + 冪等性テスト）
- リクエストスペック: AccountTitle CRUD/CSV + JournalEntry CRUD/CSV/generate
- ジョブスペック: JournalExportJob（CSV 生成 + ステータス更新）
- システムスペック: 仕訳一覧・詳細・一括生成の主要フロー

## 実装順序（TDD）

1. **Phase 1:** AccountTitle モデル（spec → migration → model）
2. **Phase 2:** JournalEntry + JournalEntryLine モデル（spec → migration → model → 既存7モデルに関連追加）
3. **Phase 3:** JournalEntryGenerator サービス（spec → service）
4. **Phase 4:** AccountTitlesController（spec → controller → views → routes → i18n）
5. **Phase 5:** JournalEntriesController（spec → controller → views → routes + generate アクション）
6. **Phase 6:** JournalExportJob + i18n + seeds + ナビゲーション
7. **Phase 7:** システムスペック + 全テスト通過確認 + lint クリア
