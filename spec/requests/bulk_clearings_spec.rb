require 'rails_helper'

RSpec.describe 'BulkClearings' do
  let!(:building) { create(:building) }
  let!(:room) { create(:room, building: building) }
  let!(:tenant) { create(:tenant, name: '山田 太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 100_000) }
  let!(:unpaid1) do
    create(:tenant_payment, contract: contract, due_date: '2024-06-01',
           amount: 100_000, status: :unpaid)
  end
  let!(:unpaid2) do
    create(:tenant_payment, contract: contract, due_date: '2024-07-01',
           amount: 100_000, status: :unpaid)
  end

  describe 'GET /bulk_clearings/new' do
    it 'アップロードフォームを表示できる' do
      get new_bulk_clearing_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('入金一括消込')
    end
  end

  describe 'POST /bulk_clearings/preview' do
    it 'CSVをアップロードしてプレビューを表示できる' do
      csv_content = "振込日,振込人名,金額\n2024-06-01,山田 太郎,100000\n"
      file = Rack::Test::UploadedFile.new(
        StringIO.new(csv_content), 'text/csv', original_filename: 'payments.csv'
      )

      post preview_bulk_clearings_path, params: { bulk_clearing: { file: file } }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('山田 太郎')
    end

    it 'ファイル未選択でリダイレクトされる' do
      post preview_bulk_clearings_path, params: { bulk_clearing: {} }
      expect(response).to redirect_to(new_bulk_clearing_path)
    end
  end

  describe 'POST /bulk_clearings' do
    it '選択した入金予定を一括消込できる' do
      post bulk_clearings_path, params: {
        clearings: {
          unpaid1.id.to_s => { match: '1', paid_date: '2024-06-01', paid_amount: '100000' },
          unpaid2.id.to_s => { match: '0' }
        }
      }

      expect(response).to redirect_to(tenant_payments_path)
      expect(unpaid1.reload.status).to eq 'paid'
      expect(unpaid1.reload.paid_amount).to eq 100_000
      expect(unpaid2.reload.status).to eq 'unpaid'
    end
  end
end
