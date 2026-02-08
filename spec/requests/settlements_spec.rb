require 'rails_helper'

RSpec.describe 'Settlements' do
  let!(:building) { create(:building) }
  let!(:room) { create(:room, building: building) }
  let!(:tenant) { create(:tenant) }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 150_000, deposit: 300_000) }

  describe 'GET /settlements' do
    it '精算一覧を表示できる' do
      create(:settlement, contract: contract)
      get settlements_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('精算一覧')
    end
  end

  describe 'GET /settlements/:id' do
    it '精算詳細を表示できる' do
      settlement = create(:settlement, contract: contract)
      get settlement_path(settlement)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /settlements/new' do
    it '新規精算フォームを表示できる' do
      get new_settlement_path(contract_id: contract.id)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /settlements（賃料精算）' do
    it '賃料精算を作成し日割り計算が行われる' do
      expect {
        post settlements_path, params: {
          settlement: {
            contract_id: contract.id,
            settlement_type: 'tenant_rent',
            termination_date: '2024-06-15',
            status: 'draft'
          }
        }
      }.to change(Settlement, :count).by(1)

      settlement = Settlement.last
      expect(settlement.daily_rent).to eq(5_000)
      expect(settlement.days_count).to eq(15)
      expect(settlement.prorated_rent).to eq(75_000)
      expect(response).to redirect_to(settlement_path(settlement))
    end
  end

  describe 'POST /settlements（敷金精算）' do
    it '敷金精算を作成し返還額が計算される' do
      expect {
        post settlements_path, params: {
          settlement: {
            contract_id: contract.id,
            settlement_type: 'tenant_deposit',
            termination_date: '2024-06-30',
            deposit_amount: 300_000,
            restoration_cost: 80_000,
            other_deductions: 20_000,
            status: 'draft'
          }
        }
      }.to change(Settlement, :count).by(1)

      settlement = Settlement.last
      expect(settlement.refund_amount).to eq(200_000)
      expect(response).to redirect_to(settlement_path(settlement))
    end
  end

  describe 'GET /settlements/:id/edit' do
    it '精算編集フォームを表示できる' do
      settlement = create(:settlement, contract: contract)
      get edit_settlement_path(settlement)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /settlements/:id' do
    it '精算を更新できる' do
      settlement = create(:settlement, contract: contract, status: :draft)
      patch settlement_path(settlement), params: {
        settlement: { status: 'confirmed' }
      }
      expect(response).to redirect_to(settlement_path(settlement))
      expect(settlement.reload.status).to eq 'confirmed'
    end
  end

  describe 'DELETE /settlements/:id' do
    it '精算を削除できる' do
      settlement = create(:settlement, contract: contract)
      expect {
        delete settlement_path(settlement)
      }.to change(Settlement, :count).by(-1)
      expect(response).to redirect_to(settlements_path)
    end
  end
end
