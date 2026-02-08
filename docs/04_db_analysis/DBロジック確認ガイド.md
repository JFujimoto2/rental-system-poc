# Oracle DBロジック確認ガイド

レガシーシステムのリプレース検討にあたり、Oracle DB内にどれだけロジックが入っているかを確認するためのSQLです。

---

## 0. 前提情報

- SI Object Browser for Oracleに接続
- `RACSYSRF01` は接続ユーザー
- `RACSYSAP01`スキーマを選択

```
■ TABLE
業務データ本体（顧客・契約・取引・マスタ・トランザクションなど）
■ INDEX
検索用インデックス
■ VIEW
複雑な結合を簡単に扱うためのビュー（アプリがよく利用）
■ PROCEDURE / FUNCTION
業務ロジック（バッチ処理や更新処理、ビジネスルール）
■ PACKAGE / PACKAGE BODY
PL/SQL のまとまった処理
→ アプリの主要処理がここに入っている可能性が高い
■ TRIGGER
データ登録・更新時の自動処理
■ SYNONYM
他スキーマのテーブルを参照する別名（ここも重要）
■ SEQUENCE
ID採番用（主キーなど）
■ MATERIALIZED VIEW / LOG
差分同期や高速参照用（バッチ系でよく使われる）
```

---

## 1. 規模感をざっくり把握

```sql
SELECT object_type, COUNT(*)
FROM all_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'TRIGGER', 'VIEW', 'TABLE')
GROUP BY object_type
ORDER BY COUNT(*) DESC;
```

```
OBJECT_TYPE	COUNT(*)
VIEW	7384
TABLE	3582
PACKAGE	398
FUNCTION	208
PROCEDURE	38
```

```sql
SELECT owner
FROM all_objects
WHERE object_type = 'VIEW'
GROUP BY owner;
```

```
OWNER:18件
APEX_050000
MDSYS
RACSYSSD01
CTXSYS
CORESYS02
RACSYSND01
SYSTEM
RACSYSAP02
RACSYSSD02
DBSNMP
GSMADMIN_INTERNAL
ORDSYS
CORESYS01
XDB
ORDDATA
RACSYSAP01
SYS
WMSYS
RACSYSND02
```

---

## 2. ストアドプロシージャ / ファンクション一覧

```sql
SELECT object_type, COUNT(*)
FROM all_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
GROUP BY object_type
ORDER BY COUNT(*) DESC;
```

```
OBJECT_TYPE	COUNT(*)
FUNCTION	208
PROCEDURE	38
```

```
SELECT *
FROM all_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
ORDER BY object_type DESC;
```

- 結果ファイル格納場所:C:\Users\jumpei921226\Documents\個人メモ\ラクシス\DB\PROCDDURE&FUNCTION一覧.xlsx

---

## 3. パッケージ一覧（PL/SQLをまとめたもの）

```sql
SELECT object_type, COUNT(*)
FROM all_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
GROUP BY object_type
ORDER BY COUNT(*) DESC;
```

```
OBJECT_TYPE	COUNT(*)
PACKAGE	398
```

```sql
SELECT *
FROM all_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY OWNER;
```

- 結果格納場所：C:\Users\jumpei921226\Documents\個人メモ\ラクシス\DB\パッケージ一覧.xlsx

```sql
SELECT owner
FROM all_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
GROUP BY OWNER;
```

```
OWNER:6件
APEX_050000
MDSYS
CTXSYS
GSMADMIN_INTERNAL
ORDSYS
ORDPLUGINS
XDB
SYS
WMSYS

```

---

## 4. トリガー一覧

```sql
SELECT COUNT(*)
FROM   ALL_TRIGGERS
ORDER BY TABLE_NAME, TRIGGER_NAME;
```

```
COUNT(*)
36
```

- 結果格納場所：C:\Users\jumpei921226\Documents\個人メモ\ラクシス\DB\トリガー一覧.xlsx

---

## 5. ビュー一覧（複雑なものはロジックを含む可能性あり）

```sql
SELECT *
FROM all_objects
WHERE object_type IN ('VIEW')
ORDER BY object_type DESC;
```

- 結果格納場所：C:\Users\jumpei921226\Documents\個人メモ\ラクシス\DB\ビュー一覧.xlsx

```sql
SELECT COUNT(*)
FROM all_objects
WHERE object_type IN ('VIEW')
ORDER BY object_type DESC;
```

```
COUNT(*)
7384
```

---

## 6. 特定オブジェクトのソースコードを確認

```sql
SELECT owner, name, type, line, text
FROM   ALL_SOURCE
WHERE  type IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER')
ORDER BY name, type, line;

```

- 結果格納：C:\Users\jumpei921226\Documents\個人メモ\ラクシス\DB\ソースコード一覧.csv

---

## 7. ソースコードの行数で規模感を把握

```sql
SELECT count(*)
FROM   ALL_SOURCE
WHERE  type IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER');
```

- 結果：120382行

---

## 移行難易度の目安

| 状況                                  | 難易度 |
| ------------------------------------- | ------ |
| プロシージャ/ファンクションが10個以下 | 低     |
| プロシージャ/ファンクションが10〜50個 | 中     |
| パッケージが多数、行数が数千行以上    | 高     |
| トリガーが多数（20個以上）            | 高     |

- 移行難易度は、激高になると判断

```
FUNCTION	208
PROCEDURE	38
TRIGGER   36
```

---

## 追加確認事項

```SQL
SELECT object_type, COUNT(*)
FROM all_objects
WHERE owner IN ('RACSYSAP01', 'RACSYSND01', 'RACSYSAP02', 'RACSYSND02')
 AND object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'TRIGGER')
GROUP BY object_type
ORDER BY COUNT(*) DESC;
```

- 結果：0件

```SQL
-- ソースコード行数も業務スキーマに絞る
SELECT owner, type, COUNT(*) as line_count
FROM ALL_SOURCE
WHERE owner IN ('RACSYSAP01', 'RACSYSND01', 'RACSYSAP02', 'RACSYSND02')
GROUP BY owner, type
ORDER BY line_count DESC;
```

- 結果：0件

```SQL
-- VIEW件数
SELECT COUNT(*)
FROM all_objects
WHERE object_type = 'VIEW'
 AND owner = 'RACSYSAP01';
```

- 結果:72件

```SQL
-- MATERIALIZED VIEW件数
SELECT COUNT(*)
FROM all_mviews
WHERE owner = 'RACSYSAP01';
```

- 結果:49件

```SQL
-- TABLE件数
SELECT COUNT(*)
FROM all_tables
WHERE owner = 'RACSYSAP01';
```

- 結果:276件
