# 認証・権限管理

## ステータス: 実装中

## 概要

Microsoft Entra ID (旧 Azure AD) による SSO ログイン。
OmniAuth + omniauth-entra-id gem で OIDC 認証を実装する。

## 権限ロール（4段階）

| ロール | 値 | 権限 |
|--------|------|------|
| admin | 0 | 全操作（ユーザー管理・設定含む） |
| manager | 1 | マスタ管理（建物・部屋・オーナー・契約の CRUD） |
| operator | 2 | 入出金操作（入金消込・オーナー支払処理・インポート） |
| viewer | 3 | 閲覧のみ（全画面の参照） |

## データモデル

### User

| カラム | 型 | 必須 | 説明 |
|--------|------|------|------|
| provider | string | YES | 認証プロバイダ（entra_id） |
| uid | string | YES | Entra ID のユーザー識別子 |
| name | string | YES | 表示名 |
| email | string | YES | メールアドレス |
| role | integer | YES | 権限ロール（enum） |

## 画面フロー

1. 未認証ユーザー → ログインページにリダイレクト
2. 「Microsoft でログイン」ボタン → Entra ID の認証画面
3. 認証成功 → コールバック → セッション作成 → 元のページに遷移
4. 認証失敗 → ログインページにエラー表示

## 権限制御

- `ApplicationController` に `before_action :require_login` を追加
- ロール別に操作可能範囲を制御する `authorize!` ヘルパー
- viewer: 閲覧系アクション (index, show) のみ許可
- operator: viewer + 入出金系の create/update/delete
- manager: operator + マスタ系の create/update/delete
- admin: 全操作 + ユーザー管理

## 実装方針

- `omniauth-entra-id` gem で OIDC 認証
- `User` モデルに `role` enum を定義
- 初回ログイン時に User レコードを自動作成（デフォルト: viewer）
- admin がユーザー一覧画面でロールを変更可能
- 開発・テスト環境ではバイパス可能な仕組み（ENV で切替）
