require 'rails_helper'

RSpec.describe 'Reports' do
  let!(:owner) { create(:owner) }
  let!(:building) { create(:building, owner: owner, name: '渋谷マンション') }
  let!(:room1) { create(:room, building: building, room_number: '101', status: :occupied) }
  let!(:room2) { create(:room, building: building, room_number: '102', status: :vacant) }
  let!(:tenant) { create(:tenant) }
  let!(:master_lease) { create(:master_lease, owner: owner, building: building) }
  let!(:contract) { create(:contract, room: room1, tenant: tenant, rent: 100_000, master_lease: master_lease) }

  describe 'GET /reports/property_pl（物件別収支サマリ）' do
    before do
      create(:tenant_payment, contract: contract, due_date: '2024-06-01', amount: 100_000,
             paid_amount: 100_000, status: :paid)
      create(:owner_payment, master_lease: master_lease, target_month: '2024-06-01',
             guaranteed_amount: 80_000, deduction: 0, net_amount: 80_000, status: :paid)
    end

    it 'レポートを表示できる' do
      get property_pl_reports_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('物件別収支サマリ')
      expect(response.body).to include('渋谷マンション')
    end

    it '期間を指定して絞り込める' do
      get property_pl_reports_path, params: { from: '2024-06-01', to: '2024-06-30' }
      expect(response).to have_http_status(:success)
    end

    it 'CSVをダウンロードできる' do
      get property_pl_reports_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/csv')
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
      expect(response.body).to include('建物名')
    end
  end

  describe 'GET /reports/aging（債権滞留表）' do
    before do
      create(:tenant_payment, contract: contract, due_date: 20.days.ago.to_date,
             amount: 100_000, status: :overdue)
      create(:tenant_payment, contract: contract, due_date: 50.days.ago.to_date,
             amount: 80_000, status: :overdue)
      create(:tenant_payment, contract: contract, due_date: 100.days.ago.to_date,
             amount: 120_000, status: :overdue)
    end

    it 'レポートを表示できる' do
      get aging_reports_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('債権滞留表')
    end

    it 'エイジング区分ごとの集計が表示される' do
      get aging_reports_path
      expect(response.body).to include('〜30日')
      expect(response.body).to include('31〜60日')
      expect(response.body).to include('61〜90日')
      expect(response.body).to include('90日超')
    end

    it 'CSVをダウンロードできる' do
      get aging_reports_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/csv')
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end
  end

  describe 'GET /reports/payment_summary（入金実績レポート）' do
    before do
      create(:tenant_payment, contract: contract, due_date: '2024-06-01',
             amount: 100_000, paid_amount: 100_000, status: :paid, payment_method: :transfer)
      create(:tenant_payment, contract: contract, due_date: '2024-07-01',
             amount: 100_000, status: :unpaid)
    end

    it 'レポートを表示できる' do
      get payment_summary_reports_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('入金実績レポート')
    end

    it '入金率が表示される' do
      get payment_summary_reports_path
      expect(response.body).to include('入金率')
    end

    it 'CSVをダウンロードできる' do
      get payment_summary_reports_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/csv')
    end
  end
end
