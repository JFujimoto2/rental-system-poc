require 'rails_helper'

RSpec.describe 'Contracts' do
  let!(:owner) { create(:owner) }
  let!(:building) { create(:building, owner: owner) }
  let!(:room) { create(:room, building: building) }
  let!(:tenant) { create(:tenant) }
  let!(:contract) { create(:contract, room: room, tenant: tenant) }

  describe 'GET /contracts' do
    it '一覧を表示できる' do
      get contracts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /contracts/:id' do
    it '詳細を表示できる' do
      get contract_path(contract)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /contracts/new' do
    it '新規作成フォームを表示できる' do
      get new_contract_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /contracts' do
    it '契約を作成できる' do
      expect {
        post contracts_path, params: {
          contract: {
            room_id: room.id,
            tenant_id: tenant.id,
            lease_type: 'ordinary',
            start_date: '2024-04-01',
            end_date: '2026-03-31',
            rent: 85_000,
            management_fee: 5_000,
            status: 'active'
          }
        }
      }.to change(Contract, :count).by(1)
      expect(response).to redirect_to(contract_path(Contract.last))
    end
  end

  describe 'GET /contracts/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_contract_path(contract)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /contracts/:id' do
    it '契約を更新できる' do
      patch contract_path(contract), params: {
        contract: { rent: 90_000 }
      }
      expect(response).to redirect_to(contract_path(contract))
      expect(contract.reload.rent).to eq 90_000
    end
  end

  describe 'DELETE /contracts/:id' do
    it '契約を削除できる' do
      expect {
        delete contract_path(contract)
      }.to change(Contract, :count).by(-1)
      expect(response).to redirect_to(contracts_path)
    end
  end
end
