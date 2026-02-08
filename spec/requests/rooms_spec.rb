require 'rails_helper'

RSpec.describe 'Rooms' do
  let!(:building) { create(:building) }
  let!(:room) { create(:room, building: building) }

  describe 'GET /rooms' do
    it '一覧を表示できる' do
      get rooms_path
      expect(response).to have_http_status(:success)
    end

    it '部屋番号で検索できる' do
      get rooms_path, params: { q: { room_number: "101" } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /rooms.csv' do
    it 'CSVをダウンロードできる' do
      get rooms_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
      expect(response.body).to include("部屋番号")
    end
  end

  describe 'GET /rooms/:id' do
    it '詳細を表示できる' do
      get room_path(room)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /rooms/new' do
    it '新規作成フォームを表示できる' do
      get new_room_path
      expect(response).to have_http_status(:success)
    end

    it 'building_idパラメータで建物を初期選択できる' do
      get new_room_path(building_id: building.id)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /rooms' do
    it '部屋を作成できる' do
      expect {
        post rooms_path, params: { room: { building_id: building.id, room_number: '301', status: 'vacant' } }
      }.to change(Room, :count).by(1)
      expect(response).to redirect_to(room_path(Room.last))
    end
  end

  describe 'GET /rooms/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_room_path(room)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /rooms/:id' do
    it '部屋を更新できる' do
      patch room_path(room), params: { room: { rent: 90_000 } }
      expect(response).to redirect_to(room_path(room))
      expect(room.reload.rent).to eq 90_000
    end
  end

  describe 'DELETE /rooms/:id' do
    it '部屋を削除できる' do
      expect {
        delete room_path(room)
      }.to change(Room, :count).by(-1)
      expect(response).to redirect_to(rooms_path)
    end
  end
end
