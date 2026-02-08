# 物件管理（建物・部屋）

## ステータス: 実装済み

## 概要

建物と部屋（区画）の基本情報を管理する CRUD 画面。
現行システムの「物件管理 > 物件・区画情報」に相当する。

## データモデル

### Building（建物）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| name | string | YES | 建物名 |
| address | string | | 住所 |
| building_type | string | | 構造（RC, SRC, 木造 等） |
| floors | integer | | 階数 |
| built_year | integer | | 築年 |
| nearest_station | string | | 最寄駅 |
| notes | text | | 備考 |

### Room（部屋）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| building_id | references | YES | 建物（外部キー） |
| room_number | string | YES | 部屋番号 |
| floor | integer | | 階数 |
| area | decimal | | 面積（㎡） |
| rent | integer | | 賃料（円） |
| status | integer | | 状態（enum） |
| room_type | string | | 間取り（1K, 2LDK 等） |
| notes | text | | 備考 |

### Room status enum

| 値 | キー | 表示名 |
|----|------|--------|
| 0 | vacant | 空室 |
| 1 | occupied | 入居中 |
| 2 | notice | 退去予定 |

## モデル関連

```
Building 1 ──── N Room
```

- `Building has_many :rooms, dependent: :destroy`
- `Room belongs_to :building`

## バリデーション

- Building: `name` が必須
- Room: `room_number` が必須、`building` が必須

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /buildings | 建物一覧 | テーブル形式で全建物を表示。部屋数カラム付き |
| GET /buildings/:id | 建物詳細 | 建物情報 + 紐づく部屋一覧 |
| GET /buildings/new | 建物登録 | 新規建物の入力フォーム |
| GET /buildings/:id/edit | 建物編集 | 既存建物の編集フォーム |
| GET /rooms | 部屋一覧 | テーブル形式で全部屋を表示。建物名カラム付き |
| GET /rooms/:id | 部屋詳細 | 部屋情報（建物へのリンク付き） |
| GET /rooms/new | 部屋登録 | 新規部屋の入力フォーム。建物をセレクトボックスで選択 |
| GET /rooms/:id/edit | 部屋編集 | 既存部屋の編集フォーム |

## 主要ファイル

- `app/models/building.rb` / `app/models/room.rb`
- `app/controllers/buildings_controller.rb` / `app/controllers/rooms_controller.rb`
- `app/views/buildings/` / `app/views/rooms/`
- `config/locales/ja.yml` — 日本語ラベル・enum 翻訳
- `db/migrate/20260208082829_create_buildings.rb`
- `db/migrate/20260208082833_create_rooms.rb`
- `spec/models/building_spec.rb` / `spec/models/room_spec.rb`
- `spec/requests/buildings_spec.rb` / `spec/requests/rooms_spec.rb`

## テスト

- モデルスペック: バリデーション、関連、enum、dependent destroy
- リクエストスペック: 全 CRUD アクションの正常系
