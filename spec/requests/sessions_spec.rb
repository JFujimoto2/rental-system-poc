require 'rails_helper'

RSpec.describe 'Sessions', :skip_auth do
  describe 'GET /login' do
    it 'ログイン画面を表示できる' do
      get login_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ログインしてください')
      expect(response.body).to include('開発用ログイン')
    end
  end

  describe 'POST /dev_login（開発用ログイン）' do
    it 'ユーザーとしてログインできる' do
      user = create(:user, :admin, name: 'テスト管理者')
      post login_as_path, params: { user_id: user.id }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('テスト管理者')
    end
  end

  describe 'DELETE /logout' do
    it 'ログアウトできる' do
      user = create(:user)
      post login_as_path, params: { user_id: user.id }
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe '未認証時のアクセス制御' do
    it '未認証ユーザーはログインページにリダイレクトされる' do
      get buildings_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe '権限制御' do
    it 'viewer は閲覧できるが作成できない（権限チェックは将来実装）' do
      user = create(:user, :viewer)
      post login_as_path, params: { user_id: user.id }
      get buildings_path
      expect(response).to have_http_status(:success)
    end

    it 'admin はユーザー管理にアクセスできる' do
      user = create(:user, :admin)
      post login_as_path, params: { user_id: user.id }
      get users_path
      expect(response).to have_http_status(:success)
    end

    it 'viewer はユーザー管理にアクセスできない' do
      user = create(:user, :viewer)
      post login_as_path, params: { user_id: user.id }
      get users_path
      expect(response).to redirect_to(root_path)
    end
  end
end
