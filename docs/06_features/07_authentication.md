# 認証・権限管理

## ステータス: 実装済

## 概要

Microsoft Entra ID (旧 Azure AD) および Google OAuth2 による SSO ログイン。
OmniAuth + omniauth-entra-id / omniauth-google-oauth2 gem で OIDC 認証を実装。
セッションベースの認証で、未ログインユーザーは全画面でログインページにリダイレクトされる。

## 使用 Gem

| Gem | バージョン | 用途 |
|-----|-----------|------|
| omniauth-entra-id | ~> 3.0 | Microsoft Entra ID (Azure AD) SSO |
| omniauth-google-oauth2 | ~> 1.2 | Google OAuth2 SSO |
| omniauth-rails_csrf_protection | ~> 1.0 | OmniAuth の CSRF 保護 |

---

## 認証フロー

### SSO ログイン（本番・ステージング）

```
ブラウザ → GET / → require_login → リダイレクト → GET /login（ログインページ）
  ↓
「Microsoft でログイン」or「Google でログイン」ボタンをクリック
  ↓
POST /auth/entra_id（or /auth/google_oauth2）→ OmniAuth ミドルウェアが処理
  ↓
外部認証プロバイダの認証画面（Microsoft or Google）
  ↓
認証成功 → GET /auth/:provider/callback → SessionsController#create
  ↓
User.find_or_create_from_omniauth で User レコード作成/更新
  ↓
session[:user_id] にユーザー ID をセット → root_path にリダイレクト
```

### 開発用バイパスログイン（development / test）

SSO の設定なしで動作確認するための仕組み。`Rails.env.local?`（development / test）のときのみ有効。

```
GET /login → ログインページ下部に「開発用ログイン」セクション表示
  ↓
DB に登録済みの User 一覧がボタンとして表示される
  ↓
ボタンクリック → POST /dev_login { user_id: X }
  ↓
SessionsController#dev_login → session[:user_id] をセット → root_path にリダイレクト
```

### 開発環境での初回セットアップ

開発用ログインを使うには、先に User レコードを作成する必要がある:

```bash
# Rails console で作成
bin/rails console
User.create!(provider: "dev", uid: "dev-admin", name: "管理者", email: "admin@example.com", role: :admin)
User.create!(provider: "dev", uid: "dev-viewer", name: "閲覧者", email: "viewer@example.com", role: :viewer)
```

または `db/seeds.rb` に追加して `bin/rails db:seed` で作成。

---

## 権限ロール（4段階）

| ロール | 値 | 日本語名 | 権限 |
|--------|------|----------|------|
| admin | 0 | 管理者 | 全操作（ユーザー管理含む） |
| manager | 1 | マネージャー | マスタ管理（建物・部屋・オーナー・契約の CRUD） |
| operator | 2 | オペレーター | 入出金操作（入金消込・オーナー支払処理・インポート） |
| viewer | 3 | 閲覧者 | 閲覧のみ（全画面の参照） |

### 権限チェックメソッド（User モデル）

```ruby
user.can_manage_users?     # admin のみ
user.can_manage_master?    # admin, manager
user.can_operate_payments? # admin, manager, operator
```

### コントローラでの権限制御

`ApplicationController` に定義された `before_action` 用ヘルパー:

```ruby
authorize_user_management!    # admin のみ → UsersController で使用
authorize_master_management!  # admin, manager（将来的に使用予定）
authorize_payment_operations! # admin, manager, operator（将来的に使用予定）
```

現在は `require_login`（全アクション）と `authorize_user_management!`（ユーザー管理画面）のみ適用済み。
他の権限チェックは将来のステップでコントローラに適用予定。

### 将来実装: コントローラ別の権限適用計画

現状はログインさえすれば全ロールが全画面で CRUD 操作可能。
将来、以下の `before_action` を各コントローラの書き込み系アクションに追加する。

| コントローラ | ヘルパー | 対象アクション | 許可ロール |
|---|---|---|---|
| `BuildingsController` | `authorize_master_management!` | create / update / destroy | admin, manager |
| `RoomsController` | `authorize_master_management!` | create / update / destroy | admin, manager |
| `OwnersController` | `authorize_master_management!` | create / update / destroy | admin, manager |
| `MasterLeasesController` | `authorize_master_management!` | create / update / destroy | admin, manager |
| `TenantsController` | `authorize_master_management!` | create / update / destroy | admin, manager |
| `ContractsController` | `authorize_master_management!` | create / update / destroy | admin, manager |
| `TenantPaymentsController` | `authorize_payment_operations!` | create / update / destroy | admin, manager, operator |
| `OwnerPaymentsController` | `authorize_payment_operations!` | create / update / destroy | admin, manager, operator |
| `ImportsController` | `authorize_payment_operations!` | preview / create | admin, manager, operator |
| `UsersController` | `authorize_user_management!` | 全アクション | admin（**適用済み**） |

実装例:

```ruby
class BuildingsController < ApplicationController
  before_action :authorize_master_management!, only: [ :create, :update, :destroy ]
  # ...
end
```

viewer ロールは index / show のみアクセス可能となり、
新規作成・編集・削除ボタンもビューで `can_manage_master?` / `can_operate_payments?` で出し分けが必要。

---

## データモデル

### users テーブル

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| id | bigint | YES | 主キー（自動採番） |
| provider | string | YES | 認証プロバイダ（`entra_id` / `google_oauth2` / `dev`） |
| uid | string | YES | プロバイダ側のユーザー識別子 |
| name | string | YES | 表示名 |
| email | string | YES | メールアドレス |
| role | integer | YES | 権限ロール（enum: 0=admin, 1=manager, 2=operator, 3=viewer） |
| created_at | datetime | YES | 作成日時 |
| updated_at | datetime | YES | 更新日時 |

### User モデルの主要ロジック

```ruby
# 初回ログイン時: provider + uid で検索、なければ新規作成（デフォルト viewer）
User.find_or_create_from_omniauth(auth)

# ロール判定
user.admin?    / user.manager?   / user.operator?  / user.viewer?
user.role_label  # => "管理者" / "マネージャー" 等（I18n 対応）
```

---

## 画面一覧

### ログインページ（`/login`）

- **コントローラ**: `SessionsController#new`
- **ビュー**: `app/views/sessions/new.html.erb`
- SSO ボタン: 環境変数が設定されているプロバイダのみ表示
  - `ENTRA_CLIENT_ID` が設定済み → 「Microsoft でログイン」ボタン表示
  - `GOOGLE_CLIENT_ID` が設定済み → 「Google でログイン」ボタン表示
- 開発用ログイン: `Rails.env.local?` のとき、DB 上の User 一覧をボタン表示

### ユーザー管理画面（`/users`） - admin のみ

- **コントローラ**: `UsersController` （`before_action :authorize_user_management!`）
- **一覧** (`/users`): 全ユーザーの名前・メール・プロバイダ・ロール表示
- **ロール変更** (`/users/:id/edit`): ロールをドロップダウンで変更

### レイアウト（共通ヘッダー）

ログイン済みのとき、ヘッダーに以下を表示:
- ナビゲーションリンク（建物、部屋、オーナー等）
- 「ユーザー管理」リンク（admin のみ）
- ユーザー名（ロール）
- ログアウトボタン

---

## ルーティング

| メソッド | パス | アクション | 説明 |
|----------|------|-----------|------|
| GET | `/login` | `sessions#new` | ログインページ表示 |
| DELETE | `/logout` | `sessions#destroy` | ログアウト |
| GET | `/auth/:provider/callback` | `sessions#create` | OmniAuth コールバック |
| GET | `/auth/failure` | `sessions#failure` | 認証失敗時 |
| POST | `/dev_login` | `sessions#dev_login` | 開発用バイパスログイン（local のみ） |
| GET | `/users` | `users#index` | ユーザー一覧（admin のみ） |
| GET | `/users/:id/edit` | `users#edit` | ロール変更画面（admin のみ） |
| PATCH | `/users/:id` | `users#update` | ロール更新（admin のみ） |

---

## 環境変数

### Microsoft Entra ID

| 変数名 | 説明 | 必須 |
|--------|------|------|
| `ENTRA_CLIENT_ID` | Entra ID アプリケーション（クライアント）ID | 本番で必須 |
| `ENTRA_CLIENT_SECRET` | クライアントシークレット | 本番で必須 |
| `ENTRA_TENANT_ID` | テナント ID | 本番で必須 |

### Google OAuth2

| 変数名 | 説明 | 必須 |
|--------|------|------|
| `GOOGLE_CLIENT_ID` | Google Cloud OAuth2 クライアント ID | 本番で必須 |
| `GOOGLE_CLIENT_SECRET` | クライアントシークレット | 本番で必須 |

**注意**: 環境変数が未設定のプロバイダは自動的にスキップされる。
開発環境では ENV 未設定のまま「開発用ログイン」だけで動作可能。

### Entra ID の設定手順

1. [Azure Portal](https://portal.azure.com/) → Microsoft Entra ID → アプリの登録
2. 新しいアプリケーションを登録
3. リダイレクト URI: `https://<ドメイン>/auth/entra_id/callback`
4. クライアントシークレットを作成
5. 上記 3 つの環境変数を設定

### Google OAuth2 の設定手順

1. [Google Cloud Console](https://console.cloud.google.com/) → API とサービス → 認証情報
2. OAuth 2.0 クライアント ID を作成
3. 承認済みリダイレクト URI: `https://<ドメイン>/auth/google_oauth2/callback`
4. 上記 2 つの環境変数を設定

---

## ファイル構成

```
app/
├── controllers/
│   ├── application_controller.rb   # require_login, authorize_* ヘルパー
│   ├── sessions_controller.rb      # ログイン/ログアウト/コールバック/dev_login
│   └── users_controller.rb         # ユーザー管理（admin のみ）
├── models/
│   └── user.rb                     # role enum, find_or_create_from_omniauth
└── views/
    ├── sessions/
    │   └── new.html.erb            # ログインページ
    ├── users/
    │   ├── index.html.erb          # ユーザー一覧
    │   └── edit.html.erb           # ロール変更
    └── layouts/
        └── application.html.erb    # 条件付きヘッダー（logged_in?）

config/
├── initializers/
│   └── omniauth.rb                 # OmniAuth ミドルウェア設定
├── locales/
│   └── ja.yml                      # User モデル・enum の日本語翻訳
└── routes.rb                       # 認証関連ルーティング

db/
└── migrate/
    └── 20260208095607_create_users.rb

spec/
├── factories/users.rb              # admin/manager/operator/viewer trait
├── models/user_spec.rb             # 17 examples
├── requests/sessions_spec.rb       # 7 examples
└── support/
    ├── authentication_helper.rb    # テスト用自動ログイン
    ├── capybara.rb                 # Playwright ドライバ（prepend_before）
    └── omniauth.rb                 # OmniAuth テストモード設定
```

---

## テスト

### テスト戦略

- **モデルテスト** (`spec/models/user_spec.rb`): バリデーション、enum、`find_or_create_from_omniauth`、権限メソッド
- **リクエストテスト** (`spec/requests/sessions_spec.rb`): dev_login、ログアウト、未認証リダイレクト、権限制御
- **システムテスト**: 全テスト（38件）で自動ログイン

### テスト用自動ログインの仕組み

`spec/support/authentication_helper.rb` で全テストに自動ログインを適用:

- **request spec**: `before(:each)` で admin ユーザーを作成し、`POST /dev_login` でログイン
- **system spec**: `before(:each)` で admin ユーザーを作成し、ログインページでボタンをクリック
- `skip_auth: true` メタデータを付けるとスキップ可能

### 重要: Playwright ドライバの実行順序

`spec/support/capybara.rb` で `config.prepend_before` を使用する必要がある。
`driven_by :playwright` は Playwright ブラウザをリセットするため、
通常の `before(:each)` だとログイン後にセッションが消える。
`prepend_before` で先にドライバを初期化してからログインすることで解決。
