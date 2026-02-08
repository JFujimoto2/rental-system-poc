require 'rails_helper'

RSpec.describe 'Buildings' do
  let!(:building) { create(:building) }

  describe 'GET /buildings' do
    it '一覧を表示できる' do
      get buildings_path
      expect(response).to have_http_status(:success)
    end

    it '名前で検索できる' do
      create(:building, name: "テスト建物")
      get buildings_path, params: { q: { name: "テスト" } }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("テスト建物")
    end

    it '検索結果件数が表示される' do
      get buildings_path, params: { q: { name: "サンプル" } }
      expect(response.body).to include("件")
    end
  end

  describe 'GET /buildings.csv' do
    it 'CSVをダウンロードできる' do
      get buildings_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get buildings_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end

    it 'CSVに日本語ヘッダーが含まれる' do
      get buildings_path(format: :csv)
      expect(response.body).to include("建物名")
    end

    it '検索条件でフィルタされたCSVをダウンロードできる' do
      create(:building, name: "CSV対象ビル")
      create(:building, name: "除外ビル")
      get buildings_path(format: :csv, q: { name: "CSV対象" })
      expect(response.body).to include("CSV対象ビル")
      expect(response.body).not_to include("除外ビル")
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
