# 物件管理 CRUD 画面の実装計画

## Context

現行の賃貸管理システム（Java 6 / Oracle）のリプレイスPoCとして、最初の管理画面を構築する。
現行システムでは「物件管理 > 物件・区画情報」が1画面で建物と区画（部屋）を管理している。
PoCでは Rails の scaffold ベースで建物・部屋の CRUD を素の Rails + CSS で実装し、Rails での開発生産性を検証する。

## データモデル

### Building（建物）
| カラム | 型 | 説明 |
|--------|------|------|
| name | string | 建物名（必須） |
| address | string | 住所 |
| building_type | string | 構造（RC, SRC, 木造 等） |
| floors | integer | 階数 |
| built_year | integer | 築年 |
| nearest_station | string | 最寄駅 |
| notes | text | 備考 |

### Room（部屋/区画）
| カラム | 型 | 説明 |
|--------|------|------|
| building | references | 建物（外部キー、必須） |
| room_number | string | 部屋番号（必須） |
| floor | integer | 階数 |
| area | decimal | 面積（㎡） |
| rent | integer | 賃料（円） |
| status | integer | 状態（enum: 空室/入居中/退去予定） |
| room_type | string | 間取り（1K, 2LDK 等） |
| notes | text | 備考 |

## 実装ステップ

### Step 1: Building の scaffold 生成
```bash
bin/rails generate scaffold Building \
  name:string address:string building_type:string \
  floors:integer built_year:integer nearest_station:string notes:text
bin/rails db:migrate
```
- モデルにバリデーション追加（name: presence）
- 日本語ラベル用に `config/locales/ja.yml` に ActiveRecord の属性名を追加

### Step 2: Room の scaffold 生成
```bash
bin/rails generate scaffold Room \
  building:references room_number:string floor:integer \
  area:decimal rent:integer status:integer room_type:string notes:text
bin/rails db:migrate
```
- モデルにバリデーション追加（building, room_number: presence）
- `status` を enum で定義（vacant: 0, occupied: 1, notice: 2）
- Building `has_many :rooms, dependent: :destroy`

### Step 3: ルーティングとナビゲーション
- `config/routes.rb`: `resources :buildings` と `resources :rooms` を追加、`root` を buildings#index に設定
- 共通レイアウト（`app/views/layouts/application.html.erb`）にヘッダーナビゲーションを追加（建物一覧・部屋一覧へのリンク）

### Step 4: ビューの日本語化と調整
- scaffold 生成されたビューのラベル・ボタンを日本語化
- `config/locales/ja.yml` に モデル名・属性名・enum値の翻訳を定義
- Room の一覧画面に建物名を表示、フォームで建物をセレクトボックスで選択可能に
- Building の詳細画面に紐づく部屋一覧を表示

### Step 5: 簡易スタイリング
- `app/assets/stylesheets/application.css` にテーブル・フォーム・ナビゲーションの基本スタイルを追加
- 管理画面らしい見た目に最低限整える（テーブル罫線、ボタンスタイル、ヘッダー背景色）

### Step 6: テスト
- scaffold で自動生成されるコントローラテスト・モデルテストを確認・修正
- バリデーションのテストを追加
- `bin/rails test` で全テスト通過を確認

## 対象ファイル（主要）

- `app/models/building.rb` / `app/models/room.rb`
- `app/controllers/buildings_controller.rb` / `app/controllers/rooms_controller.rb`
- `app/views/buildings/` / `app/views/rooms/`
- `app/views/layouts/application.html.erb`
- `app/assets/stylesheets/application.css`
- `config/routes.rb`
- `config/locales/ja.yml`
- `db/migrate/` — 2つのマイグレーションファイル
- `test/models/` / `test/controllers/`

## 検証方法

1. `bin/rails db:migrate` が成功すること
2. `bin/rails server` で起動し、ブラウザで以下を確認:
   - `/buildings` — 建物一覧・新規作成・編集・削除
   - `/rooms` — 部屋一覧・新規作成（建物選択）・編集・削除
   - 建物詳細から紐づく部屋一覧が見えること
3. `bin/rails test` で全テスト通過
4. `bin/rubocop` でlint違反なし
