# 問い合わせ・修繕依頼

## ステータス: 実装済

## 概要

入居者からの問い合わせ・修繕依頼を一元管理する機能。受付から対応完了までのステータスを追跡し、
必要に応じて工事（Construction）と紐付けて修繕対応を管理する。

## 業務フロー

```
入居者から連絡
  → 問い合わせ登録
  → 担当者アサイン
  → 対応（現地確認、修繕手配）
  → 完了報告
  → クローズ
       ↓（修繕が必要な場合）
     Construction を作成してリンク
```

## データモデル

### Inquiry（問い合わせ）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| room_id | references | 対象部屋（任意） |
| tenant_id | references | 対象入居者（任意） |
| assigned_user_id | references | 担当者（任意、User） |
| construction_id | references | 関連工事（任意） |
| category | integer | カテゴリ enum |
| priority | integer | 優先度 enum |
| status | integer | 状態 enum |
| title | string | 件名（必須） |
| description | text | 内容 |
| response | text | 対応内容 |
| received_on | date | 受付日 |
| resolved_on | date | 解決日 |
| notes | text | 備考 |

## enum 定義

### category（カテゴリ）

| 値 | 日本語 |
|----|--------|
| repair | 修繕依頼 |
| complaint | クレーム |
| question | 質問 |
| noise | 騒音 |
| leak | 漏水 |
| other | その他 |

### priority（優先度）

| 値 | 日本語 |
|----|--------|
| low | 低 |
| normal | 通常 |
| high | 高 |
| urgent | 緊急 |

### status（状態）

| 値 | 日本語 | 説明 |
|----|--------|------|
| received | 受付 | 問い合わせを受け付けた状態 |
| assigned | 担当割当 | 担当者がアサインされた |
| in_progress | 対応中 | 対応を進めている |
| completed | 完了 | 対応完了 |
| closed | クローズ | 最終確認完了 |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /inquiries | 問い合わせ一覧 | 検索（建物名・入居者名・カテゴリ・優先度・状態）+ CSV |
| GET /inquiries/:id | 問い合わせ詳細 | 内容・対応状況の表示 |
| GET /inquiries/new | 問い合わせ登録 | 新規問い合わせフォーム |
| GET /inquiries/:id/edit | 問い合わせ編集 | 内容の修正・対応内容入力 |

## 工事との連携

- フォームで「関連工事」を選択可能
- 修繕依頼から工事が発生した場合、Construction レコードを作成して紐付け
- 詳細画面で関連工事へのリンクを表示

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208140733_create_inquiries.rb` | テーブル作成 |
| `app/models/inquiry.rb` | モデル（enum, バリデーション, search） |
| `app/controllers/inquiries_controller.rb` | CRUD + 検索 + CSV |
| `app/views/inquiries/` | index, show, new, edit, _form |

## テスト

- モデルスペック: association, validation, enum, search, label (**実装済**)
- リクエストスペック: CRUD + 検索 + CSV (**実装済**)
- システムスペック: 新規作成・一覧→詳細遷移・編集 (**実装済**)
