require 'rails_helper'

RSpec.describe 'Constructions' do
  let!(:construction) { create(:construction) }

  describe 'GET /constructions' do
    it '一覧を表示できる' do
      get constructions_path
      expect(response).to have_http_status(:success)
    end

    it '建物名で検索できる' do
      building = create(:building, name: "検索対象ビル")
      room = create(:room, building: building)
      create(:construction, room: room, title: "検索工事")
      get constructions_path, params: { q: { building_name: "検索対象" } }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("検索工事")
    end
  end

  describe 'GET /constructions.csv' do
    it 'CSVをダウンロードできる' do
      get constructions_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get constructions_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end
  end

  describe 'GET /constructions/:id' do
    it '詳細を表示できる' do
      get construction_path(construction)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /constructions/new' do
    it '新規作成フォームを表示できる' do
      get new_construction_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /constructions' do
    let(:room) { create(:room) }

    it '工事を作成できる' do
      expect {
        post constructions_path, params: { construction: {
          room_id: room.id, title: "新規工事", construction_type: "restoration", status: "draft"
        } }
      }.to change(Construction, :count).by(1)
      expect(response).to redirect_to(construction_path(Construction.last))
    end
  end

  describe 'GET /constructions/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_construction_path(construction)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /constructions/:id' do
    it '工事を更新できる' do
      patch construction_path(construction), params: { construction: { title: "更新後工事" } }
      expect(response).to redirect_to(construction_path(construction))
      expect(construction.reload.title).to eq "更新後工事"
    end
  end

  describe 'DELETE /constructions/:id' do
    it '工事を削除できる' do
      expect {
        delete construction_path(construction)
      }.to change(Construction, :count).by(-1)
      expect(response).to redirect_to(constructions_path)
    end
  end
end
