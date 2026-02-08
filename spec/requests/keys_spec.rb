require 'rails_helper'

RSpec.describe 'Keys' do
  let!(:key) { create(:key) }

  describe 'GET /keys' do
    it '一覧を表示できる' do
      get keys_path
      expect(response).to have_http_status(:success)
    end

    it '鍵種別で検索できる' do
      get keys_path, params: { q: { key_type: "main" } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /keys.csv' do
    it 'CSVをダウンロードできる' do
      get keys_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get keys_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end
  end

  describe 'GET /keys/:id' do
    it '詳細を表示できる' do
      get key_path(key)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /keys/new' do
    it '新規作成フォームを表示できる' do
      get new_key_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /keys' do
    let(:room) { create(:room) }

    it '鍵を作成できる' do
      expect {
        post keys_path, params: { key: {
          room_id: room.id, key_type: "main", status: "in_stock", key_number: "K-100"
        } }
      }.to change(Key, :count).by(1)
      expect(response).to redirect_to(key_path(Key.last))
    end
  end

  describe 'GET /keys/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_key_path(key)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /keys/:id' do
    it '鍵を更新できる' do
      patch key_path(key), params: { key: { key_number: "K-999" } }
      expect(response).to redirect_to(key_path(key))
      expect(key.reload.key_number).to eq "K-999"
    end
  end

  describe 'DELETE /keys/:id' do
    it '鍵を削除できる' do
      expect {
        delete key_path(key)
      }.to change(Key, :count).by(-1)
      expect(response).to redirect_to(keys_path)
    end
  end
end
