# 入金一括消込

## ステータス: 実装済

## 概要

銀行入金明細 CSV をアップロードし、入金予定（`TenantPayment`）との自動マッチング＋一括消込を行う機能。
現行システムの「入金取込・一括消込」「入金消込」に相当する。

手作業での個別消込を大幅に効率化する日常業務の中核機能。

## 処理フロー

```
1. CSV アップロード（GET /bulk_clearings/new）
     ↓
2. CSV パース（振込日・振込人名・金額を抽出）
     ↓
3. 入金予定（TenantPayment: unpaid/overdue）と自動照合
   - 名前 + 金額が完全一致 → マッチ
   - 名前のみ一致 → 候補として表示
   - マッチなし → 未マッチリストに表示
     ↓
4. プレビュー画面で確認（POST /bulk_clearings/preview）
   - マッチ済み一覧（チェックボックスで選択/解除）
   - 未マッチ一覧（候補表示）
     ↓
5. 一括消込実行（POST /bulk_clearings）
   - 選択した入金予定の status/paid_amount/paid_date を更新
```

## CSV フォーマット

BOM 付き UTF-8 対応。ヘッダー行あり。

| 列 | ヘッダー | 内容 | 例 |
|----|---------|------|-----|
| 1 | 振込日 | 入金日（YYYY-MM-DD） | 2024-06-01 |
| 2 | 振込人名 | 振込依頼人名 | 山田 太郎 |
| 3 | 金額 | 入金額（数値） | 100000 |

## マッチングロジック（BulkClearingMatcher）

### マッチ条件
1. **振込人名**と**入居者名**が一致（空白・全角スペースを除去して比較）
2. **振込金額**と**請求金額**（`TenantPayment.amount`）が一致

### マッチ対象
- `status` が `unpaid` または `overdue` の `TenantPayment` のみ
- `paid` や `partial` は対象外

### マッチ種別
| 種別 | 条件 | 表示 |
|------|------|------|
| exact（完全一致） | 名前 + 金額が一致 | 「完全一致」バッジ |
| 候補 | 名前は一致するが金額が不一致 | 未マッチ欄に候補として表示 |

### 名前正規化
```ruby
def normalize_name(name)
  name.to_s.gsub(/[\s　]/, "")  # 半角・全角スペースを除去
end
```

## 消込処理

選択した入金予定に対して以下を更新:

| カラム | 値 |
|--------|-----|
| `paid_amount` | CSV の金額 |
| `paid_date` | CSV の振込日 |
| `status` | 金額 >= 請求額なら `paid`、未満なら `partial` |
| `payment_method` | `transfer`（振込） |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /bulk_clearings/new | アップロード | CSV ファイル選択 + フォーマット説明 |
| POST /bulk_clearings/preview | プレビュー | マッチ結果確認 + チェックボックス選択 |
| POST /bulk_clearings | 消込実行 | 一括更新 → テナント入金一覧にリダイレクト |

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/controllers/bulk_clearings_controller.rb` | アップロード・プレビュー・消込実行 |
| `app/services/bulk_clearing_matcher.rb` | マッチングロジック（Service クラス） |
| `app/views/bulk_clearings/new.html.erb` | アップロード画面 |
| `app/views/bulk_clearings/preview.html.erb` | プレビュー画面 |

## ナビゲーション

「入出金管理」メニューに「入金一括消込」リンクを追加。

## テスト

- サービスクラススペック: 完全一致・空白正規化・金額不一致・名前不一致・入金済除外 (**実装済**)
- リクエストスペック: アップロード画面表示・CSV プレビュー・ファイル未選択エラー・一括消込実行 (**実装済**)
