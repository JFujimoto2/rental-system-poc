# 契約更新管理

## ステータス: 実装済

## 概要

転貸借契約の更新時期を管理し、賃料改定交渉から新契約作成までの一連のフローを追跡する機能。
バッチジョブ（ContractRenewalReminderJob）により、期限3ヶ月前の契約に自動でリマインダーを生成する。

## 業務フロー

```
契約期限3ヶ月前
  → 更新案内作成（バッチで自動生成 or 手動）
  → 賃料改定交渉
  → 更新合意 → 新Contract作成（旧契約 terminated）
  or → 更新辞退 → 解約手続きへ
```

## データモデル

### ContractRenewal（契約更新）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| contract_id | references | 元の契約（必須） |
| new_contract_id | references | 更新後の新契約（任意、更新完了時にセット） |
| status | integer | 状態 enum |
| renewal_date | date | 更新日 |
| current_rent | integer | 現在賃料 |
| proposed_rent | integer | 提案賃料 |
| renewal_fee | integer | 更新料 |
| tenant_notified_on | date | 入居者通知日 |
| notes | text | 備考 |

## ステータス

| 値 | 日本語 | 説明 |
|----|--------|------|
| pending | 未着手 | 更新案内未送付 |
| notified | 通知済 | 入居者に通知済み |
| negotiating | 交渉中 | 賃料改定等の交渉中 |
| agreed | 合意 | 更新条件で合意 |
| renewed | 更新完了 | 新契約作成済み |
| declined | 辞退 | 入居者が更新を辞退 |
| cancelled | キャンセル | 更新手続きのキャンセル |

## 更新完了時のロジック

1. 新しい Contract レコードを作成（同じ room, tenant, master_lease で新しい期間）
2. 旧 Contract を `terminated` に更新
3. ContractRenewal の `new_contract_id` をセット、status を `renewed` に

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /contract_renewals | 契約更新一覧 | 検索（建物名・入居者名・状態）+ CSV |
| GET /contract_renewals/:id | 契約更新詳細 | 更新内容の表示 |
| GET /contract_renewals/new | 契約更新登録 | 新規契約更新フォーム |
| GET /contract_renewals/:id/edit | 契約更新編集 | 更新内容の修正 |

## 契約画面との連携

- 契約詳細画面（`/contracts/:id`）に「更新履歴」セクションを追加
- 状態・更新日・現在賃料・提案賃料・更新料を一覧表示
- 「契約更新を作成」リンクで `contract_id` を自動セットし、`current_rent` を契約の賃料で事前入力

## バッチジョブ

**ContractRenewalReminderJob** — 詳細は `docs/06_features/jobs/08_contract_renewal_reminder.md` を参照

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208140717_create_contract_renewals.rb` | テーブル作成 |
| `app/models/contract_renewal.rb` | モデル（enum, バリデーション, search） |
| `app/controllers/contract_renewals_controller.rb` | CRUD + 検索 + CSV |
| `app/views/contract_renewals/` | index, show, new, edit, _form |
| `app/views/contracts/show.html.erb` | 更新履歴セクション追加 |
| `app/jobs/contract_renewal_reminder_job.rb` | 自動リマインダー生成ジョブ |

## テスト

- モデルスペック: association, validation, enum, search, status_label (**実装済**)
- リクエストスペック: CRUD + 検索 + CSV (**実装済**)
- ジョブスペック: 自動生成・既存スキップ・terminated スキップ (**実装済**)
- システムスペック: 新規作成・一覧→詳細遷移・契約画面連携 (**実装済**)
