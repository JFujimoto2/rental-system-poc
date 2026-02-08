# 鍵管理

## ステータス: 実装済

## 概要

部屋ごとの鍵の所在・状態を管理する機能。入居時の貸出・退去時の回収・紛失時の対応を
鍵履歴（KeyHistory）で追跡する。

## 業務フロー

```
部屋に鍵を登録
  → 入居時: 鍵を入居者に貸出（issued）
  → 退去時: 鍵を回収（returned → in_stock）
  → 紛失時: 紛失記録（lost_reported → lost）→ 交換（replaced）
```

## データモデル

### Key（鍵）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| room_id | references | 部屋（必須） |
| key_type | integer | 鍵種別 enum |
| key_number | string | 鍵番号 |
| status | integer | 状態 enum |
| notes | text | 備考 |

### KeyHistory（鍵履歴）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| key_id | references | 鍵（必須） |
| tenant_id | references | 入居者（任意） |
| action | integer | アクション enum |
| acted_on | date | 実施日（必須） |
| notes | text | 備考 |

## enum 定義

### key_type（鍵種別）

| 値 | 日本語 |
|----|--------|
| main | 本鍵 |
| duplicate | 合鍵 |
| spare | スペア |
| mailbox | 郵便受け |
| auto_lock | オートロック |

### status（状態）

| 値 | 日本語 |
|----|--------|
| in_stock | 在庫 |
| issued | 貸出中 |
| lost | 紛失 |
| disposed | 廃棄 |

### action（アクション）— KeyHistory

| 値 | 日本語 |
|----|--------|
| issued | 貸出 |
| returned | 返却 |
| lost_reported | 紛失届 |
| replaced | 交換 |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /keys | 鍵一覧 | 検索（建物名・部屋番号・鍵種別・状態）+ CSV |
| GET /keys/:id | 鍵詳細 | 鍵情報 + 鍵履歴の表示 |
| GET /keys/new | 鍵登録 | 新規鍵フォーム |
| GET /keys/:id/edit | 鍵編集 | 鍵情報の修正 |

## 部屋画面との連携

- 部屋詳細画面（`/rooms/:id`）に「鍵一覧」セクションを追加
- 鍵種別・鍵番号・状態を一覧表示
- 「この部屋に鍵を追加」リンクで `room_id` を自動セット

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208140749_create_keys.rb` | Keyテーブル作成 |
| `db/migrate/20260208140750_create_key_histories.rb` | KeyHistoryテーブル作成 |
| `app/models/key.rb` | モデル（enum, バリデーション, search） |
| `app/models/key_history.rb` | モデル（enum, バリデーション） |
| `app/controllers/keys_controller.rb` | CRUD + 検索 + CSV |
| `app/views/keys/` | index, show（履歴セクション含む）, new, edit, _form |
| `app/views/rooms/show.html.erb` | 鍵一覧セクション追加 |

## テスト

- モデルスペック: Key（association, validation, enum, search, label）+ KeyHistory（association, validation, enum, label）(**実装済**)
- リクエストスペック: CRUD + 検索 + CSV (**実装済**)
- システムスペック: 新規作成・一覧→詳細遷移・部屋画面連携 (**実装済**)
