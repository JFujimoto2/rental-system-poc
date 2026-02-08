require 'rails_helper'

RSpec.describe 'Buildings' do
  let!(:building) { create(:building) }

  describe 'GET /buildings' do
    it '一覧を表示できる' do
      get buildings_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /buildings/:id' do
    it '詳細を表示できる' do
      get building_path(building)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /buildings/new' do
    it '新規作成フォームを表示できる' do
      get new_building_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /buildings' do
    it '建物を作成できる' do
      expect {
        post buildings_path, params: { building: { name: '新規ビル', address: '東京都千代田区' } }
      }.to change(Building, :count).by(1)
      expect(response).to redirect_to(building_path(Building.last))
    end
  end

  describe 'GET /buildings/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_building_path(building)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /buildings/:id' do
    it '建物を更新できる' do
      patch building_path(building), params: { building: { name: '更新後ビル' } }
      expect(response).to redirect_to(building_path(building))
      expect(building.reload.name).to eq '更新後ビル'
    end
  end

  describe 'DELETE /buildings/:id' do
    it '建物を削除できる' do
      expect {
        delete building_path(building)
      }.to change(Building, :count).by(-1)
      expect(response).to redirect_to(buildings_path)
    end
  end
end
