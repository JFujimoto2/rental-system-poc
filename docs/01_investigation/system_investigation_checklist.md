# Java 6 システム調査・判断タスク

## 概要

Java 6 + Spring改造独自フレームワークのシステムについて、延命/リファクタリング/リプレースの判断材料を集める。

---

## 1. 規模感の調査

### コード量の計測

- [x] Javaファイル数を確認
  - 2653

```bash
find . -name "*.java" | wc -l
```

- [x] 行数を確認（clocを使用）

```bash
cloc --include-lang=Java .
```

````
9537 text files.
Unique:      100 files                                       Unique:      200 files                                       Unique:      300 files                                       Unique:      400 files                                       Unique:      500 files                                       Unique:      600 files                                       Unique:      700 files                                       Unique:      800 files                                       Unique:      900 files                                       Unique:     1000 files                                       Unique:     1100 files                                       Unique:     1200 files                                       Unique:     1300 files                                       Unique:     1400 files                                       Unique:     1500 files                                       Unique:     1600 files                                       Unique:     1700 files                                       Unique:     1800 files                                       Unique:     1900 files                                       Unique:     2000 files                                       Unique:     2100 files                                       Unique:     2200 files                                       Unique:     2300 files                                       Unique:     2400 files                                       Unique:     2500 files                                       Unique:     2600 files                                       Unique:     2700 files                                       Unique:     2800 files                                       Unique:     2900 files                                       Unique:     3000 files                                       Unique:     3100 files                                       Unique:     3200 files                                           7330 unique files.
    8176 files ignored.

github.com/AlDanial/cloc v 1.98  T=10.79 s (163.8 files/s, 116279.0 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Java                          1767         154233         264752         835115
-------------------------------------------------------------------------------
SUM:                          1767         154233         264752         835115
-------------------------------------------------------------------------------
```

- [x] 結果を記録：184475 行 / 1,746 ファイル

### 構造的な規模

- [x] 画面数（JSP/HTML）を確認

```bash
find . -name "*.jsp" -o -name "*.html" | wc -l
````

→104

- [ ] テーブル数を確認（DDL or ER図から）
- [ ] 外部連携の洗い出し
- API連携：
- バッチ連携：
- ファイル連携：

---

## 2. フレームワーク構成の把握

### 依存ライブラリの確認

- [ ] 依存関係を出力

```bash
# Mavenの場合
mvn dependency:tree > dependencies.txt

# Antの場合
ls -la lib/*.jar > dependencies.txt
```

mavenバージョンが古すぎて以下のコマンドが動かない  
`mvn dependency:tree > dependencies.txt`  
今後mavenのバージョンをローカルでだけ挙げて、pom.xmlを更新→dependenciesを洗い出す。
・以下ドキュメントを参照のこと  
[mavenバージョンアップ方針](C:\Users\jumpei921226\Documents\個人メモ\ラクシス\依存関係\mavenバージョンアップ.md)

- [x] Springのバージョンを特定：使用なし
- [x] O/Rマッパーを特定：未使用
- [x] Webフレームワークを特定：未使用 （Spring MVC / Struts / 独自）

#### プロジェクト技術スタック分析（pom.xml ベース）

```
- Spring：未使用（依存関係に Spring artifacts なし）
- Webフレームワーク：未使用（Struts / Spring MVC / Servlet API なし）
- O/Rマッパー：未使用（Hibernate / iBATIS / MyBatis なし）
  → JDBC（ojdbc6）+ Apache DBCP で DB接続
- ログ：log4j 1.2.15（旧式）
- Excel：jxl / Apache POI 3.6（古い両方使用）
- PDF：iText 1.4.5（サポート終了）
- その他：
  commons-collections, commons-logging, commons-dbcp,
  自社独自 mbb\_\* モジュール多数

- packaging：jar（Webアプリではない。バッチ or 共通ライブラリ）
- 単体テスト：JUnit 3.8.1
- Java：ojdbc6 より Java6/7 世代が濃厚
```

#### 全体像：

フレームワーク非使用の自社独自基盤を中心に構築された、
2000年代後半のレガシーJavaアプリの構成。

### 設定ファイルの確認

- [ ] applicationContext.xml の場所と内容確認
- [x] web.xml の確認
  - Servers/ローカル・ホスト の Tomcat7 (Java7)-config/web.xml
    - こちらはほとんどテンプレート（考慮不要）
  - /home/jumpei921226/projects/racsys/trunk/src/main/webapp/WEB-INF/web.xml
    - ほとんどはこちらに記載している形
- [ ] その他独自設定ファイルの洗い出し

### WEB-INF/web.xml 解析結果

```- Servlet API: 2.4（web.xml中心の古い構成）
- Front Controller:
  - jp.co.bbs.unit.sys.AppController
  - URL: /appcontroller
  - init-param:
    - APPLICATION_PATH = ${wbf.ap.path}
    - DATA_SOURCE_NAME = java:comp/env/${appcontroller.ds.name}

- DBアクセス用サーブレット:
  - class = ${wbf.ap.db}（外部設定で差し替え）
  - URL: /dbaccess
  - init-param:
    - APPLICATION_PATH = ${wbf.ap.path}
    - DATA_SOURCE_NAME = java:comp/env/${appcontroller.ds.name}

- 設定はプレースホルダ（${...}）で外出し
- JNDI DataSource（java:comp/env/）を使用
```

---

## 3. 独自フレームワークの分析

### 基本情報

- [x] 独自フレームワークのパッケージ名を特定
  - MBB(ビジネスブレイン太田昭和社が作成したフレームワーク)
  - 画面定義・プロセス定義・テーブル定義に分けて記載している
- [x] 独自フレームワークのソースコード場所を特定
  - view: `racsys/trunk/src/main/webapp/jsp`
  - controller: `jp.co.bbs.unit.item.mst`
  - model: ``
- [x] ドキュメントの有無を確認:メンテはされていなさそうだが、設計書はあり

### カスタム範囲の特定

- [ ] どのレイヤーをカスタムしているか確認
- [ ] DIコンテナ
- [ ] MVCフレームワーク
- [ ] トランザクション管理
- [ ] その他（　　　　　）

### リスク評価

- [x] Springの内部API（`org.springframework.internal.*`等）への依存を確認
  - 結果：ヒットせず

```bash
grep -r "org.springframework.internal" --include="*.java"
grep -r "org.springframework.core.internal" --include="*.java"
```

- [x] 非推奨APIの使用状況を確認

### DB評価

- [DBロジック確認ガイド参照](C:\Users\jumpei921226\Documents\個人メモ\ラクシス\DB\DBロジック確認ガイド.md)
- [] PL/SQL本数:
- [] 正規化:

## 4. 現状の運用・保守状況

- [x] 年間の改修頻度：8 回程度(不具合改修含め)
- [x] 保守コスト（月額）：800 万円
- [x] 対応できるエンジニア：社内0名 / 社外4～8名
- [x] テストコードの有無・カバレッジ：なし
- [x] ドキュメント整備状況：最新化はされてなさそうだが、構築時の独自フレームワークとかのドキュメントはそろっている
  - C:\ApplCosmos\ApplProgram\TortoiseSVN\repositories\mnt

---

## 5. 事業観点の確認

- [ ] このシステムの想定利用期間：あと\_\_\_年
- [ ] ビジネス要件の変化予定：
- [ ] 予算確保の見込み：

---

## 6. 判断マトリクス

調査結果を元に評価：

| 観点       | 延命 | リファクタリング | リプレース |
| ---------- | ---- | ---------------- | ---------- |
| 技術リスク |      |                  |            |
| コスト     |      |                  |            |
| 期間       |      |                  |            |
| 人材確保   |      |                  |            |
| 事業継続性 |      |                  |            |

---

## 調査結果サマリ

### 規模感

-

### フレームワーク構成

-

### 独自フレームワークのリスク

-

### 推奨方針

- ***

## 次のアクション

1.
1.
1.
