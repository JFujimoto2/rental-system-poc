# Excel インポート

## ステータス: 実装済

## 概要

roo gem を使用した .xlsx ファイルの一括取込機能。
PoC 計画「4.2 Excel インポート機能」の検証項目。

Building（建物）と Room（部屋）の一括インポートを最初の対象とする。

## 画面フロー

1. **アップロード画面** — ファイル選択 + インポート種別選択
2. **プレビュー画面** — 読み取り結果の確認 + 行単位バリデーションエラー表示
3. **確定処理** — データ保存 + 結果表示

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /imports/new | アップロード | ファイル選択 |
| POST /imports/preview | プレビュー | 読み取り結果の確認 |
| POST /imports | 確定 | データ保存 |

## Excel ファイルフォーマット

### 建物インポート

| 列 | ヘッダー | カラム | 必須 |
|----|----------|--------|------|
| A | 建物名 | name | YES |
| B | 住所 | address | |
| C | 構造 | building_type | |
| D | 階数 | floors | |
| E | 築年 | built_year | |
| F | 最寄駅 | nearest_station | |
| G | 備考 | notes | |

### 部屋インポート

| 列 | ヘッダー | カラム | 必須 |
|----|----------|--------|------|
| A | 建物名 | building.name（既存建物と照合） | YES |
| B | 部屋番号 | room_number | YES |
| C | 階数 | floor | |
| D | 面積 | area | |
| E | 賃料 | rent | |
| F | 間取り | room_type | |
| G | 状態 | status（空室/入居中/退去予定） | |
| H | 備考 | notes | |

## バリデーション

- 必須項目チェック
- データ型チェック（数値カラムに文字列が入っていないか等）
- 参照整合性チェック（部屋インポート時に建物名が存在するか）
- 重複チェック

## 実装方針

- `app/services/excel_importer/` に Service クラスを配置
- `ExcelImporter::BuildingImporter` / `ExcelImporter::RoomImporter`
- コントローラーは `ImportsController` に統合

## テスト

- Service クラスの単体テスト（正常系・エラー系）
- リクエストスペック（アップロード → プレビュー → 確定）
- システムスペック（E2E）
