# Oracle DBロジック調査結果レポート

## 調査概要

|項目 |内容 |
|------|----------------------------------------------|
|対象システム|レガシー賃貸物件管理システム |
|DB |Oracle |
|対象スキーマ|RACSYSAP01, RACSYSND01, RACSYSAP02, RACSYSND02|
|調査目的 |Railsへのリプレースに向けたDB側ロジック量の把握 |

-----

## 調査結果サマリー

### 全体の規模（all_objects）

|オブジェクト種別 |件数 |
|---------|-----|
|VIEW |7,384|
|TABLE |3,582|
|PACKAGE |398 |
|FUNCTION |208 |
|PROCEDURE|38 |
|TRIGGER |36 |

### 業務スキーマに絞った結果

|オブジェクト種別 |件数 |
|------------|-----|
|PROCEDURE |**0**|
|FUNCTION |**0**|
|PACKAGE |**0**|
|PACKAGE BODY|**0**|
|TRIGGER |**0**|

-----

## 重要な発見

### PACKAGEのオーナー分析

全398件のPACKAGEは以下のオーナーに属していた：

```
APEX_050000, MDSYS, CTXSYS, GSMADMIN_INTERNAL, 
ORDSYS, ORDPLUGINS, XDB, SYS, WMSYS
```

**→ 全てOracle標準/システムスキーマであり、業務ロジックは含まれていない**

### Oracle DBの実際の役割

```
Oracle DB = 純粋なデータストレージ
 ├── テーブル（データ保管）
 ├── インデックス（検索高速化）
 ├── ビュー（結合の簡略化）
 └── シーケンス（ID採番）

ビジネスロジック = 全てJavaアプリ側に実装
```

-----

## 移行難易度評価

### 当初の想定 vs 実態

|評価タイミング|難易度 |根拠 |
|-------|--------|---------------------------------------|
|当初の想定 |**激高** |FUNCTION 208件、PROCEDURE 38件、TRIGGER 36件|
|実態判明後 |**中〜中高**|業務スキーマにPL/SQLが0件 |

### 難易度下方修正の理由

1. **PL/SQL変換が不要** - DB側にビジネスロジックが存在しない
1. **データ移行がシンプル** - テーブル構造とデータのみの移行
1. **隠れたリスクが少ない** - DB側の地雷がない

-----

## 移行における影響分析

|観点 |評価|備考 |
|------|--|--------------------------------|
|データ移行 |◎ |テーブル構造とデータのみ |
|ロジック移行|◎ |PL/SQL変換不要 |
|VIEW対応|△ |7,384件あるが、Railsのスコープ/関連で段階的に置換可能|
|リスク |◎ |DB側の隠れた地雷なし |

-----

## 残存する確認事項

### 優先度：高

1. **Javaアプリのコード規模・構造**
- こちらが移行の主戦場
- コード行数、クラス数、パッケージ構成の把握
1. **外部連携の数と複雑さ**
- SaaS連携
- ファイル連携
- API連携

### 優先度：中

1. **VIEWの依存関係**
- アプリがどのVIEWを使用しているか
- 複雑なVIEWの特定と分析
1. **シーケンスの使用状況**
- ID採番ロジックの把握

-----

## 結論

**Oracle DBは純粋なデータストアとして機能しており、ビジネスロジックはJavaアプリ側に集中している。**

これにより、DB移行のリスクは大幅に軽減され、PoC計画における「DBロジック移行」の工数見積もりを下方修正できる。

月額800万円のシステムとしては、意外とDB設計は素直であり、Railsへのリプレースは技術的に十分実現可能と判断できる。

-----

## 使用したSQL

### 規模感の把握

```sql
SELECT object_type, COUNT(*)
FROM all_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'TRIGGER', 'VIEW', 'TABLE')
GROUP BY object_type
ORDER BY COUNT(*) DESC;
```

### 業務スキーマに絞った確認

```sql
SELECT object_type, COUNT(*)
FROM all_objects
WHERE owner IN ('RACSYSAP01', 'RACSYSND01', 'RACSYSAP02', 'RACSYSND02')
 AND object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'TRIGGER')
GROUP BY object_type
ORDER BY COUNT(*) DESC;
```

### ソースコード行数（業務スキーマ）

```sql
SELECT owner, type, COUNT(*) as line_count
FROM ALL_SOURCE
WHERE owner IN ('RACSYSAP01', 'RACSYSND01', 'RACSYSAP02', 'RACSYSND02')
GROUP BY owner, type
ORDER BY line_count DESC;
```

-----

*調査日: 2025年1月*