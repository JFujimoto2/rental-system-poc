# 承認ワークフロー

## ステータス: 実装済

## 概要

契約の作成・変更に1段階承認フロー（申請→承認/却下）を導入する機能。
既存システムの「承認受付一覧」「承認状況一覧」「申請状況一覧」に相当する。

PoC ではシンプルな1段階承認を実装。operator が契約を作成すると自動で承認申請が生成され、
manager/admin が承認・却下を行う。

## データモデル

### Approval（承認）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| approvable_type | string | 承認対象モデル名（polymorphic） |
| approvable_id | bigint | 承認対象ID |
| requester_id | bigint | 申請者（User、必須） |
| approver_id | bigint | 承認者（User、null可） |
| status | integer | 状態（0: pending, 1: approved, 2: rejected） |
| requested_at | datetime | 申請日時 |
| decided_at | datetime | 承認/却下日時 |
| comment | text | 承認者コメント |

Polymorphic 設計により、将来的に Contract 以外のモデル（Settlement 等）にも承認フローを拡張可能。

## ステータス

| 状態 | 日本語 | 説明 |
|------|--------|------|
| pending | 承認待ち | 申請済み、承認者の対応待ち |
| approved | 承認済 | 承認され、対象が有効化された |
| rejected | 却下 | 却下された |

## 承認フロー

```
1. operator が契約を新規作成（status: applying）
     ↓
2. 自動で Approval レコードが生成（status: pending）
   ※ admin/manager が作成した場合は承認不要（Approval 非生成）
     ↓
3. manager/admin が承認待ち一覧で確認
     ↓
4a. 承認 → Contract.status を active に自動更新
4b. 却下 → コメント付きで却下（Contract は applying のまま）
```

## ロール別の動作

| ロール | 契約作成時 | 承認操作 |
|--------|----------|---------|
| admin | 承認不要（直接作成） | 承認・却下可能 |
| manager | 承認不要（直接作成） | 承認・却下可能 |
| operator | 承認申請を自動生成 | 承認操作不可 |
| viewer | 作成不可 | 承認操作不可 |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /approvals | 承認待ち一覧 | pending ステータスの承認一覧 |
| GET /approvals/my_requests | 申請状況一覧 | 自分が申請した承認の履歴 |
| GET /approvals/:id | 承認詳細 | 承認内容の確認 + 承認/却下操作 |
| PATCH /approvals/:id/approve | 承認実行 | ステータスを approved に更新 |
| PATCH /approvals/:id/reject | 却下実行 | ステータスを rejected に更新 |

## 契約画面との連携

- 契約詳細画面（`/contracts/:id`）に「承認状態」セクションを表示
- 承認履歴（申請者・状態・承認者・処理日時）を一覧表示
- 承認詳細へのリンク

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208131823_create_approvals.rb` | Approvalテーブル作成 |
| `app/models/approval.rb` | モデル（enum, バリデーション, approve!/reject!） |
| `app/models/user.rb` | `can_approve?` メソッド追加 |
| `app/models/contract.rb` | `has_many :approvals` 追加 |
| `app/controllers/approvals_controller.rb` | 一覧・詳細・承認・却下 |
| `app/controllers/contracts_controller.rb` | 自動承認申請生成ロジック追加 |
| `app/views/approvals/` | index, my_requests, show |
| `app/views/contracts/show.html.erb` | 承認状態セクション追加 |
| `app/helpers/application_helper.rb` | `approvable_summary` ヘルパー追加 |

## ナビゲーション

ヘッダーに「承認」メニューグループを追加:
- 承認待ち一覧
- 自分の申請一覧

## テスト

- モデルスペック: association, validation, enum, approve!, reject!, scope, status_label（11テスト）(**実装済**)
- リクエストスペック: 一覧・詳細・承認・却下・自動承認申請（9テスト）(**実装済**)
- システムスペック: 承認待ち一覧・承認操作・申請状況一覧・契約連携（4テスト）(**実装済**)
