require 'rails_helper'

RSpec.describe 'Vendors' do
  let!(:vendor) { create(:vendor) }

  describe 'GET /vendors' do
    it '一覧を表示できる' do
      get vendors_path
      expect(response).to have_http_status(:success)
    end

    it '名前で検索できる' do
      create(:vendor, name: "ABC工務店")
      get vendors_path, params: { q: { name: "ABC" } }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("ABC工務店")
    end
  end

  describe 'GET /vendors.csv' do
    it 'CSVをダウンロードできる' do
      get vendors_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get vendors_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end

    it 'CSVに日本語ヘッダーが含まれる' do
      get vendors_path(format: :csv)
      expect(response.body).to include("業者名")
    end
  end

  describe 'GET /vendors/:id' do
    it '詳細を表示できる' do
      get vendor_path(vendor)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /vendors/new' do
    it '新規作成フォームを表示できる' do
      get new_vendor_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /vendors' do
    it '業者を作成できる' do
      expect {
        post vendors_path, params: { vendor: { name: "新規業者" } }
      }.to change(Vendor, :count).by(1)
      expect(response).to redirect_to(vendor_path(Vendor.last))
    end
  end

  describe 'GET /vendors/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_vendor_path(vendor)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /vendors/:id' do
    it '業者を更新できる' do
      patch vendor_path(vendor), params: { vendor: { name: "更新後業者" } }
      expect(response).to redirect_to(vendor_path(vendor))
      expect(vendor.reload.name).to eq "更新後業者"
    end
  end

  describe 'DELETE /vendors/:id' do
    it '業者を削除できる' do
      expect {
        delete vendor_path(vendor)
      }.to change(Vendor, :count).by(-1)
      expect(response).to redirect_to(vendors_path)
    end
  end
end
