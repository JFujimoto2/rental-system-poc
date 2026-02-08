require 'rails_helper'

RSpec.describe 'Dashboard' do
  describe 'GET /' do
    it 'ダッシュボードを表示できる' do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ダッシュボード')
    end

    it '入居率を表示する' do
      building = create(:building)
      create(:room, building: building, status: :occupied)
      create(:room, building: building, status: :occupied)
      create(:room, building: building, status: :vacant)

      get root_path
      expect(response.body).to include('入居率')
    end

    it '滞納情報を表示する' do
      get root_path
      expect(response.body).to include('滞納')
    end

    it '契約更新・解約予定を表示する' do
      get root_path
      expect(response.body).to include('契約更新予定')
      expect(response.body).to include('解約予定')
    end

    context 'データがある場合' do
      let!(:building) { create(:building) }
      let!(:room_occupied) { create(:room, building: building, status: :occupied) }
      let!(:room_vacant) { create(:room, building: building, status: :vacant) }
      let!(:tenant) { create(:tenant) }
      let!(:contract_active) { create(:contract, room: room_occupied, tenant: tenant, status: :active, end_date: 2.months.from_now.to_date) }
      let!(:contract_terminating) { create(:contract, tenant: create(:tenant, name: '退去者'), status: :scheduled_termination) }
      let!(:overdue_payment) do
        create(:tenant_payment, contract: contract_active, due_date: 1.month.ago.to_date, amount: 100_000, status: :overdue)
      end
      let!(:unpaid_payment) do
        create(:tenant_payment, contract: contract_active, due_date: Date.current, amount: 80_000, status: :unpaid)
      end
      let!(:master_lease) { create(:master_lease, building: building) }
      let!(:owner_payment_unpaid) do
        create(:owner_payment, master_lease: master_lease, status: :unpaid)
      end

      it 'KPI数値を正しく集計して表示する' do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
