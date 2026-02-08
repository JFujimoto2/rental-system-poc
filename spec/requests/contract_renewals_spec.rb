require 'rails_helper'

RSpec.describe 'ContractRenewals' do
  let!(:contract_renewal) { create(:contract_renewal) }

  describe 'GET /contract_renewals' do
    it '一覧を表示できる' do
      get contract_renewals_path
      expect(response).to have_http_status(:success)
    end

    it '状態で検索できる' do
      create(:contract_renewal, status: :agreed)
      get contract_renewals_path, params: { q: { status: "agreed" } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /contract_renewals.csv' do
    it 'CSVをダウンロードできる' do
      get contract_renewals_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get contract_renewals_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end
  end

  describe 'GET /contract_renewals/:id' do
    it '詳細を表示できる' do
      get contract_renewal_path(contract_renewal)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /contract_renewals/new' do
    it '新規作成フォームを表示できる' do
      get new_contract_renewal_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /contract_renewals' do
    let(:contract) { create(:contract) }

    it '契約更新を作成できる' do
      expect {
        post contract_renewals_path, params: { contract_renewal: {
          contract_id: contract.id, status: "pending", current_rent: 80000
        } }
      }.to change(ContractRenewal, :count).by(1)
      expect(response).to redirect_to(contract_renewal_path(ContractRenewal.last))
    end
  end

  describe 'GET /contract_renewals/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_contract_renewal_path(contract_renewal)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /contract_renewals/:id' do
    it '契約更新を更新できる' do
      patch contract_renewal_path(contract_renewal), params: { contract_renewal: { proposed_rent: 85000 } }
      expect(response).to redirect_to(contract_renewal_path(contract_renewal))
      expect(contract_renewal.reload.proposed_rent).to eq 85000
    end
  end

  describe 'DELETE /contract_renewals/:id' do
    it '契約更新を削除できる' do
      expect {
        delete contract_renewal_path(contract_renewal)
      }.to change(ContractRenewal, :count).by(-1)
      expect(response).to redirect_to(contract_renewals_path)
    end
  end
end
