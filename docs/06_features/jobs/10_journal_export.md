# JournalExportJob（会計仕訳エクスポート）

## ステータス: 未実装

## 概要

承認済み（approved）の仕訳データを OBIC7 連携用の汎用 CSV 形式でエクスポートするバッチジョブ。
エクスポート完了後、対象仕訳のステータスを `exported` に更新する。

## 処理フロー

```
1. status = approved の JournalEntry を取得
2. 仕訳明細（JournalEntryLine）を結合
3. CSV データを生成（OBIC7 プレースホルダ形式）
4. 対象仕訳の status を exported に更新
5. 結果サマリを返却
```

## 対象データ

- `JournalEntry.where(status: :approved)` を対象
- `journal_entry_lines` を `includes` で事前ロード
- `entry_date` の昇順でソート

## CSV フォーマット（OBIC7 プレースホルダ）

| # | カラム名 | 説明 | 例 |
|---|---------|------|-----|
| 1 | 仕訳日 | entry_date（YYYY-MM-DD） | 2026-01-15 |
| 2 | 借方科目コード | debit 側の account_title.code | 111 |
| 3 | 借方科目名 | debit 側の account_title.name | 普通預金 |
| 4 | 貸方科目コード | credit 側の account_title.code | 411 |
| 5 | 貸方科目名 | credit 側の account_title.name | 転貸賃料収入 |
| 6 | 金額 | total_amount | 80000 |
| 7 | 摘要 | description | テナント入金: 山田太郎 2026年1月分 |

**注意:** 1仕訳に複数の借方/貸方がある場合は、明細行ごとに1行を出力する。

## CSV ヘッダー（BOM 付き UTF-8）

```csv
仕訳日,借方科目コード,借方科目名,貸方科目コード,貸方科目名,金額,摘要
```

## 実行方法

```ruby
# Solid Queue で実行
JournalExportJob.perform_later

# 手動実行
JournalExportJob.perform_now
```

## 戻り値

ジョブ完了後、Rails.logger に以下を出力:

```
JournalExportJob: 15件の仕訳をエクスポートしました
```

## エラーハンドリング

- 承認済み仕訳が0件の場合: 正常終了（スキップログを出力）
- CSV 生成中のエラー: ログ出力して例外を再 raise（Solid Queue のリトライに委ねる）

## テスト観点

- 承認済み仕訳が正しく CSV に変換されること
- エクスポート後のステータスが `exported` に更新されること
- 承認済み仕訳が0件の場合にエラーにならないこと
- `draft` や `exported` の仕訳が対象外であること

## 関連ファイル（予定）

| ファイル | 内容 |
|---------|------|
| `app/jobs/journal_export_job.rb` | ジョブ本体 |
| `spec/jobs/journal_export_job_spec.rb` | ジョブスペック |
