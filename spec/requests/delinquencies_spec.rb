require 'rails_helper'

RSpec.describe 'Delinquencies' do
  let!(:building) { create(:building) }
  let!(:room) { create(:room, building: building) }
  let!(:tenant) { create(:tenant) }
  let!(:contract) { create(:contract, room: room, tenant: tenant) }

  describe 'GET /delinquencies' do
    it '滞納一覧を表示できる' do
      get delinquencies_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('滞納一覧')
    end

    context '滞納データがある場合' do
      let!(:overdue_30) do
        create(:tenant_payment, contract: contract, due_date: 20.days.ago.to_date,
               amount: 100_000, status: :overdue)
      end
      let!(:overdue_60) do
        create(:tenant_payment, contract: contract, due_date: 50.days.ago.to_date,
               amount: 80_000, status: :overdue)
      end
      let!(:overdue_90) do
        create(:tenant_payment, contract: contract, due_date: 100.days.ago.to_date,
               amount: 120_000, status: :overdue)
      end
      let!(:partial) do
        create(:tenant_payment, contract: contract, due_date: 10.days.ago.to_date,
               amount: 90_000, paid_amount: 50_000, status: :partial)
      end
      let!(:paid) do
        create(:tenant_payment, contract: contract, due_date: 5.days.ago.to_date,
               amount: 85_000, status: :paid)
      end

      it '滞納・一部入金のみ表示する（入金済は除外）' do
        get delinquencies_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(tenant.name)
      end

      it '入居者名で検索できる' do
        get delinquencies_path, params: { q: { tenant_name: tenant.name } }
        expect(response).to have_http_status(:success)
      end

      it '滞納期間で絞り込める' do
        get delinquencies_path, params: { q: { aging: '90over' } }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /delinquencies.csv' do
    it 'CSVをダウンロードできる' do
      create(:tenant_payment, contract: contract, due_date: 10.days.ago.to_date,
             amount: 100_000, status: :overdue)

      get delinquencies_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
      expect(response.body).to include("入居者")
    end
  end
end
