require 'rails_helper'

RSpec.describe 'Owners' do
  let!(:owner) { create(:owner) }

  describe 'GET /owners' do
    it '一覧を表示できる' do
      get owners_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /owners/:id' do
    it '詳細を表示できる' do
      get owner_path(owner)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /owners/new' do
    it '新規作成フォームを表示できる' do
      get new_owner_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /owners' do
    it 'オーナーを作成できる' do
      expect {
        post owners_path, params: { owner: { name: '新規オーナー', phone: '090-0000-0000' } }
      }.to change(Owner, :count).by(1)
      expect(response).to redirect_to(owner_path(Owner.last))
    end
  end

  describe 'GET /owners/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_owner_path(owner)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /owners/:id' do
    it 'オーナーを更新できる' do
      patch owner_path(owner), params: { owner: { name: '更新後オーナー' } }
      expect(response).to redirect_to(owner_path(owner))
      expect(owner.reload.name).to eq '更新後オーナー'
    end
  end

  describe 'DELETE /owners/:id' do
    it 'オーナーを削除できる' do
      expect {
        delete owner_path(owner)
      }.to change(Owner, :count).by(-1)
      expect(response).to redirect_to(owners_path)
    end
  end
end
