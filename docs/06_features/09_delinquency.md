# 滞納管理

## ステータス: 実装済

## 概要

入金期日を過ぎた未入金・一部入金を自動検出し、滞納一覧として表示する機能。
現行システムの「滞納情報作成」「滞納情報」に相当する。

新規テーブルは追加せず、`TenantPayment` の既存データのみで実現。

## 滞納判定ロジック

以下の条件に合致するレコードを「滞納」として検出する:

1. `status` が `overdue`（滞納）のもの
2. `status` が `partial`（一部入金）のもの
3. `status` が `unpaid`（未入金）かつ `due_date < 今日` のもの

```ruby
TenantPayment
  .where(status: [:overdue, :partial])
  .or(TenantPayment.where(status: :unpaid).where("due_date < ?", Date.current))
```

## 滞納期間（エイジング）分類

| 分類 | 条件 | 表示色 |
|------|------|--------|
| 〜30日 | `due_date` が 30日以内 | 黄色（aging-normal） |
| 31〜60日 | `due_date` が 31〜60日前 | オレンジ（aging-warning） |
| 61〜90日 | `due_date` が 61〜90日前 | 赤（aging-danger） |
| 90日超 | `due_date` が 90日以上前 | 濃赤（aging-critical） |

## 検索条件

| フィールド | クエリ種別 |
|-----------|-----------|
| 入居者名 | ILIKE（joins: contract → tenant） |
| 建物名 | ILIKE（joins: contract → room → building） |
| 滞納期間 | select（〜30日 / 31〜60日 / 61〜90日 / 90日超） |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /delinquencies | 滞納一覧 | 滞納件数・金額サマリ + テーブル |
| GET /delinquencies.csv | CSV ダウンロード | 滞納一覧の CSV 出力 |

## 表示項目

### サマリ
- 合計件数
- 滞納額合計（未収額の合計）

### テーブル
| 列 | 内容 |
|----|------|
| 入居者 | 入居者詳細へリンク |
| 建物 | 建物名 |
| 部屋 | 部屋番号 |
| 入金期日 | due_date |
| 滞納日数 | エイジングバッジ（色分け） |
| 請求金額 | amount |
| 入金額 | paid_amount |
| 未収額 | amount - paid_amount（赤字表示） |
| 状態 | status_label |

## CSV 出力カラム

| ヘッダー | 内容 |
|---------|------|
| 入居者 | tenant.name |
| 建物 | building.name |
| 部屋 | room.room_number |
| 入金期日 | due_date |
| 滞納日数 | 日数計算 |
| 請求金額 | amount |
| 入金額 | paid_amount |
| 未収額 | amount - paid_amount |
| 状態 | status_label |

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `app/controllers/delinquencies_controller.rb` | 滞納検出・検索・CSV 出力 |
| `app/views/delinquencies/index.html.erb` | 滞納一覧ビュー |
| `app/helpers/application_helper.rb` | `aging_class` ヘルパーメソッド |
| `app/assets/stylesheets/application.css` | エイジング用 CSS |

## ナビゲーション

「入出金管理」メニューに「滞納一覧」リンクを追加。

## テスト

- リクエストスペック: 一覧表示・検索・エイジング絞り込み・CSV ダウンロード (**実装済**)
