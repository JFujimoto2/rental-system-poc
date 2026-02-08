# 追加調査項目チェックリスト

## 調査済み項目

| カテゴリ | 項目             | 内容                                |
| -------- | ---------------- | ----------------------------------- |
| 技術     | 言語・FW         | Java 6 / MBBフレームワーク / Oracle |
| 技術     | コード規模       | 2,653ファイル / 835,115行           |
| 技術     | 画面数           | 104画面                             |
| 技術     | DBロジック       | PL/SQL 0件（Java側に集中）          |
| 技術     | テーブル数       | 276テーブル（業務スキーマ）         |
| 運用     | 保守費           | 月800万円                           |
| 運用     | 認証             | IP制限 + ベーシック認証             |
| 運用     | 同時接続ユーザー | 最大100人程度（社内専用システム）   |
| 連携     | 外部システム     | アプラス、OBIC、GoWeb、保証会社     |

---

## 追加調査項目

### 優先度：高（PoC・移行判断に直結）

#### 1. データ量の把握

- [ ] 本番DBサイズ（GB）
- [x] 主要テーブルのレコード数
  - 最多データ件数：54451909件
  - 最多テーブルサイズ：146432MB
  - スキーマ全体サイズ：479.94GB

```sql
-- 主要テーブルのレコード数を確認
SELECT table_name, num_rows, last_analyzed
FROM all_tables
WHERE owner = 'RACSYSAP01'
ORDER BY num_rows DESC NULLS LAST;
```

```sql
-- テーブルごとのサイズ（MB）
SELECT
 segment_name AS table_name,
 ROUND(bytes / 1024 / 1024, 2) AS size_mb
FROM dba_segments
WHERE owner = 'RACSYSAP01'
 AND segment_type = 'TABLE'
ORDER BY bytes DESC;
```

```sql
-- スキーマ全体のサイズ
SELECT
 owner,
 ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS size_gb
FROM dba_segments
WHERE owner IN ('RACSYSAP01', 'RACSYSND01', 'RACSYSAP02', 'RACSYSND02')
GROUP BY owner
ORDER BY size_gb DESC;
```

#### 2. バッチ処理一覧

- [x] 日次バッチの一覧と実行時間：31本（内IFは17本）
- [x] 月次バッチの一覧と実行時間：0本
- [x] バッチの依存関係：基本的にCSV読み込み→DB反映って順のバッチが計4本。（ジョブが２つ） CSV出力→バックアップ作成が計4本。
- [x] スキーマ名：RACSYSND01, RACSYSSD01

- 下記SQLではヒットしない

```sql
-- ジョブ一覧の確認（Oracle Scheduler）
SELECT
 job_name,
 job_type,
 enabled,
 state,
 repeat_interval,
 last_start_date,
 next_run_date
FROM all_scheduler_jobs
WHERE owner IN ('RACSYSAP01', 'RACSYSND01')
ORDER BY job_name;
```

```sql
-- 旧形式のジョブ（DBMS_JOB）
SELECT
 job,
 what,
 interval,
 last_date,
 next_date,
 broken
FROM all_jobs
ORDER BY job;
```

※ Javaバッチの場合はcronやタスクスケジューラの設定を確認

#### 3. 外部連携の仕様

#### アプラス

- [x] アプラス連携
  - 2本（DP-121*口座振替依頼作成*口座振替依頼データ、DP-131*入金取込・一括消込*口座振替結果データ）
    - 口座振替依頼データは弊社から送信（ファイルサーバー（s-syscp）配置&楽楽販売API実行）
    - 主に翌月分賃料を、エンド口座から引き落とすための依頼データを、アプラスに送信する。
      （エンド入金先＝ＣＩ口座またはオーナー口座）- 口座振替結果データ
    - 上記５に対応する引落結果を受信する。(s-syscp?)
- [x] ファイルフォーマット（全銀？独自CSV？固定長？）：固定長
- [x] 連携タイミング（日次？月次？）
  - 日次
- [x] 送信方法（SFTP？画面アップロード？）
  - 依頼：画面ダウンロード＞手動配置かも？＞楽楽販売API
  - 受取：管理画面アップロード
- [x] 結果ファイルの形式：CSV（固定長）
- [x] 連携仕様書の有無・入手可否：ただしアップデートされていない
  - C:\ApplCosmos\ApplProgram\TortoiseSVN\repositories\mnt\2*内部設計\21*機能設計\211*機能設計書\DP*入出金管理\DP-121\_口座振替依頼作成
  - C:\ApplCosmos\ApplProgram\TortoiseSVN\repositories\mnt\2*内部設計\21*機能設計\211*機能設計書\DP*入出金管理\DP-131\_入金取込・一括消込

#### OBIC

- [x] OBIC連携
  - 5本（銀行マスター全件データ, 支払先マスター全件データ, 支払先口座マスター全件データ, 賃転貸売上・入金・振替仕訳データ, 賃転貸出金予定データ）
- [x] 連携方式（CSV？API？ファイル転送？）
  - FTP(File Transfer Protocol)
- [x] 仕訳生成のタイミング（入金時？月次締め時？）
  - 35機能（オーナー契約、エンド契約、優勝工事、入金、出金、一括消込、相殺、振込、オーナー賃料、賃転貸振替処理）
- [ ] 勘定科目のマッピング表
  - 要BBS確認(多分なし)
- [ ] 連携仕様書の有無・入手可否
  - これもないかな？

---

### 優先度：中（業務フロー見直しに必要）

#### 4. 画面利用状況

- [x] 各画面の利用頻度（アクセスログがあれば）
- [ ] 使われていない画面の特定
  - アクセスログが画面よりアクションごとの制御になっているから具体的には不明

```sql
-- サービスログがあれば利用状況を確認
SELECT
  COUNT(*) AS access_count,
  COUNT(DISTINCT A.userid) AS unique_users
FROM RACSYSAP01.SERVICELOG A;
```

・以下が結果(1/13~2/5までのログ)

```
ACCESS_COUNT	UNIQUE_USERS
658	11
```

#### 5. システム外運用の把握

- [ ] Excelで管理しているデータはあるか
- [ ] 手作業で行っている業務はあるか
  - ファイル連携のほとんどが手作業
- [ ] システムへの不満・要望

※ヒアリングベースで確認

---

### 優先度：低（本開発フェーズで可）

#### 6. その他の確認事項

- [ ] 障害履歴（直近1〜2年）
- [ ] 保守契約の更新時期
- [ ] 個人情報の匿名化ルール（データ移行時に必要）

---

## 確認用SQL補足

### インデックス一覧

```sql
SELECT
 index_name,
 table_name,
 uniqueness,
 status
FROM all_indexes
WHERE owner = 'RACSYSAP01'
ORDER BY table_name, index_name;
```

### 外部キー制約一覧

```sql
SELECT
 a.constraint_name,
 a.table_name,
 b.column_name,
 a.r_constraint_name
FROM all_constraints a
JOIN all_cons_columns b
 ON a.constraint_name = b.constraint_name AND a.owner = b.owner
WHERE a.owner = 'RACSYSAP01'
 AND a.constraint_type = 'R'
ORDER BY a.table_name;
```

### シーケンス一覧

```sql
SELECT
 sequence_name,
 last_number,
 increment_by,
 cache_size
FROM all_sequences
WHERE sequence_owner = 'RACSYSAP01'
ORDER BY sequence_name;
```

- 結果：0件

---

_作成日: 2025年2月_
