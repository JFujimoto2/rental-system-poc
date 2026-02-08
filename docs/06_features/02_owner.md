# オーナー（支払先）管理

## ステータス: 実装済み

## 概要

物件のオーナー（支払先）情報を管理する CRUD 画面。
現行システムの「賃貸管理 > オーナー契約 > 支払先情報（オーナー情報）」に相当する。
建物にオーナーを紐づけ、後続のオーナー契約・入出金管理の基盤となるマスタ。

## データモデル

### Owner（オーナー）

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| name | string | YES | オーナー名 |
| name_kana | string | | オーナー名カナ |
| phone | string | | 電話番号 |
| email | string | | メールアドレス |
| postal_code | string | | 郵便番号 |
| address | string | | 住所 |
| bank_name | string | | 銀行名 |
| bank_branch | string | | 支店名 |
| account_type | string | | 口座種別（普通/当座） |
| account_number | string | | 口座番号 |
| account_holder | string | | 口座名義 |
| notes | text | | 備考 |

## モデル関連

```
Owner 1 ──── N Building 1 ──── N Room
```

- `Owner has_many :buildings`
- `Building belongs_to :owner`（owner_id カラムを追加）

## バリデーション

- Owner: `name` が必須

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /owners | オーナー一覧 | テーブル形式で全オーナーを表示。所有建物数カラム付き |
| GET /owners/:id | オーナー詳細 | オーナー情報（口座情報含む） + 所有建物一覧 |
| GET /owners/new | オーナー登録 | 新規オーナーの入力フォーム |
| GET /owners/:id/edit | オーナー編集 | 既存オーナーの編集フォーム |

## 既存画面への変更

- 建物フォーム: オーナー選択セレクトボックスを追加
- 建物一覧: オーナー名カラムを追加
- 建物詳細: オーナー名（リンク付き）を表示
- ナビゲーション: 「オーナー一覧」リンクを追加

## 実装方針

- scaffold ベースで Owner の CRUD を生成
- Building に `owner_id` を追加するマイグレーション（null 許可）
- TDD で進める（spec を先に書いてから実装）
- 口座情報はフォーム内で「口座情報」セクションとしてグループ化

## テスト（予定）

- モデルスペック: バリデーション、関連
- リクエストスペック: 全 CRUD アクションの正常系
- Building との紐づけテスト
