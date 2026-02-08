require 'rails_helper'

RSpec.describe 'MasterLeases' do
  let!(:owner) { create(:owner) }
  let!(:building) { create(:building, owner: owner) }
  let!(:master_lease) { create(:master_lease, owner: owner, building: building) }

  describe 'GET /master_leases' do
    it '一覧を表示できる' do
      get master_leases_path
      expect(response).to have_http_status(:success)
    end

    it 'オーナーで検索できる' do
      get master_leases_path, params: { q: { owner_id: owner.id } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /master_leases.csv' do
    it 'CSVをダウンロードできる' do
      get master_leases_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
      expect(response.body).to include("契約形態")
    end
  end

  describe 'GET /master_leases/:id' do
    it '詳細を表示できる' do
      get master_lease_path(master_lease)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /master_leases/new' do
    it '新規作成フォームを表示できる' do
      get new_master_lease_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /master_leases' do
    it 'マスターリース契約を作成できる' do
      expect {
        post master_leases_path, params: {
          master_lease: {
            owner_id: owner.id,
            building_id: building.id,
            contract_type: 'sublease',
            start_date: '2024-04-01',
            end_date: '2026-03-31',
            guaranteed_rent: 500_000,
            rent_review_cycle: 24,
            status: 'active'
          }
        }
      }.to change(MasterLease, :count).by(1)
      expect(response).to redirect_to(master_lease_path(MasterLease.last))
    end
  end

  describe 'GET /master_leases/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_master_lease_path(master_lease)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /master_leases/:id' do
    it 'マスターリース契約を更新できる' do
      patch master_lease_path(master_lease), params: {
        master_lease: { guaranteed_rent: 450_000 }
      }
      expect(response).to redirect_to(master_lease_path(master_lease))
      expect(master_lease.reload.guaranteed_rent).to eq 450_000
    end
  end

  describe 'DELETE /master_leases/:id' do
    it 'マスターリース契約を削除できる' do
      expect {
        delete master_lease_path(master_lease)
      }.to change(MasterLease, :count).by(-1)
      expect(response).to redirect_to(master_leases_path)
    end
  end
end
