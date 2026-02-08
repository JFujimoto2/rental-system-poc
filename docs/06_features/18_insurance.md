# 保険管理

## ステータス: 実装済

## 概要

建物単位・部屋単位の保険を管理する機能。火災保険・地震保険・借家人賠償保険などの
証券情報・補償内容・期限を一元管理し、バッチジョブ（InsuranceExpirationJob）で
期限切れ前のアラートを自動生成する。

## 業務フロー

```
建物取得時 → 火災保険加入
入居者契約時 → 借家人賠償保険確認
  → 保険期限管理
  → 期限前に更新手続き（バッチで期限切れアラート）
```

## データモデル

### Insurance（保険）テーブル

| カラム | 型 | 説明 |
|--------|------|------|
| building_id | references | 建物（任意 — 建物保険の場合） |
| room_id | references | 部屋（任意 — 入居者保険の場合） |
| insurance_type | integer | 保険種別 enum |
| status | integer | 状態 enum |
| policy_number | string | 証券番号 |
| provider | string | 保険会社名 |
| coverage_amount | integer | 補償額 |
| premium | integer | 保険料 |
| start_date | date | 開始日 |
| end_date | date | 終了日 |
| notes | text | 備考 |

**バリデーション:** `building_id` か `room_id` のいずれかが必須（両方 nil は不可）

## enum 定義

### insurance_type（保険種別）

| 値 | 日本語 |
|----|--------|
| fire | 火災保険 |
| earthquake | 地震保険 |
| tenant_liability | 借家人賠償 |
| facility_liability | 施設賠償 |
| other | その他 |

### status（状態）

| 値 | 日本語 | 説明 |
|----|--------|------|
| active | 有効 | 保険が有効な状態 |
| expiring_soon | 期限間近 | 30日以内に期限切れ（バッチで自動更新） |
| expired | 期限切れ | 保険期限が切れた状態 |
| cancelled | 解約 | 保険を解約した状態 |

## 画面一覧

| パス | 画面 | 説明 |
|------|------|------|
| GET /insurances | 保険一覧 | 検索（建物名・保険種別・状態・保険会社名）+ CSV |
| GET /insurances/:id | 保険詳細 | 保険情報の表示 |
| GET /insurances/new | 保険登録 | 新規保険フォーム |
| GET /insurances/:id/edit | 保険編集 | 保険情報の修正 |

## バッチジョブ

**InsuranceExpirationJob** — 詳細は `docs/06_features/jobs/09_insurance_expiration.md` を参照

## 実装ファイル

| ファイル | 内容 |
|---------|------|
| `db/migrate/20260208140806_create_insurances.rb` | テーブル作成 |
| `app/models/insurance.rb` | モデル（enum, バリデーション, search, カスタムバリデーション） |
| `app/controllers/insurances_controller.rb` | CRUD + 検索 + CSV |
| `app/views/insurances/` | index, show, new, edit, _form |
| `app/jobs/insurance_expiration_job.rb` | 期限切れ検知ジョブ |

## テスト

- モデルスペック: association, validation, enum, search, label, カスタムバリデーション (**実装済**)
- リクエストスペック: CRUD + 検索 + CSV (**実装済**)
- ジョブスペック: active→expiring_soon 更新・30日以上先スキップ・既存 expiring_soon スキップ (**実装済**)
- システムスペック: 新規作成・一覧→詳細遷移・編集 (**実装済**)
