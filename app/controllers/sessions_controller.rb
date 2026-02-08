class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create, :failure, :dev_login ]

  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)
    session[:user_id] = user.id
    redirect_to root_path, notice: "#{user.name} としてログインしました。"
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "ログアウトしました。"
  end

  def failure
    redirect_to login_path, alert: "認証に失敗しました: #{params[:message]}"
  end

  # テスト・開発環境用のバイパスログイン
  def dev_login
    return head(:not_found) unless Rails.env.local?

    user = User.find(params[:user_id])
    session[:user_id] = user.id
    redirect_to root_path, notice: "#{user.name} としてログインしました（開発モード）。"
  end
end
