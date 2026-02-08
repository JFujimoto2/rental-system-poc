require 'rails_helper'

RSpec.describe 'Inquiries' do
  let!(:inquiry) { create(:inquiry) }

  describe 'GET /inquiries' do
    it '一覧を表示できる' do
      get inquiries_path
      expect(response).to have_http_status(:success)
    end

    it 'カテゴリで検索できる' do
      get inquiries_path, params: { q: { category: "repair" } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /inquiries.csv' do
    it 'CSVをダウンロードできる' do
      get inquiries_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get inquiries_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end
  end

  describe 'GET /inquiries/:id' do
    it '詳細を表示できる' do
      get inquiry_path(inquiry)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /inquiries/new' do
    it '新規作成フォームを表示できる' do
      get new_inquiry_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /inquiries' do
    it '問い合わせを作成できる' do
      expect {
        post inquiries_path, params: { inquiry: {
          title: "テスト問い合わせ", category: "repair", status: "received"
        } }
      }.to change(Inquiry, :count).by(1)
      expect(response).to redirect_to(inquiry_path(Inquiry.last))
    end
  end

  describe 'GET /inquiries/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_inquiry_path(inquiry)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /inquiries/:id' do
    it '問い合わせを更新できる' do
      patch inquiry_path(inquiry), params: { inquiry: { title: "更新後問い合わせ" } }
      expect(response).to redirect_to(inquiry_path(inquiry))
      expect(inquiry.reload.title).to eq "更新後問い合わせ"
    end
  end

  describe 'DELETE /inquiries/:id' do
    it '問い合わせを削除できる' do
      expect {
        delete inquiry_path(inquiry)
      }.to change(Inquiry, :count).by(-1)
      expect(response).to redirect_to(inquiries_path)
    end
  end
end
