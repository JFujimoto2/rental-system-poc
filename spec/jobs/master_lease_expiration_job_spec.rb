require 'rails_helper'

RSpec.describe MasterLeaseExpirationJob, type: :job do
  describe '#perform' do
    it 'end_date 超過の active な MasterLease を terminated にする' do
      ml = create(:master_lease, status: :active, end_date: 1.day.ago.to_date)

      described_class.perform_now

      expect(ml.reload.status).to eq 'terminated'
    end

    it '配下の active な契約も terminated にする' do
      ml = create(:master_lease, status: :active, end_date: 1.day.ago.to_date)
      contract = create(:contract, master_lease: ml, status: :active)

      described_class.perform_now

      expect(contract.reload.status).to eq 'terminated'
    end

    it '配下の scheduled_termination な契約も terminated にする' do
      ml = create(:master_lease, status: :active, end_date: 1.day.ago.to_date)
      contract = create(:contract, master_lease: ml, status: :scheduled_termination,
                        end_date: 1.month.from_now.to_date)

      described_class.perform_now

      expect(contract.reload.status).to eq 'terminated'
    end

    it 'end_date が未来の MasterLease は更新しない' do
      ml = create(:master_lease, status: :active, end_date: 1.month.from_now.to_date)

      described_class.perform_now

      expect(ml.reload.status).to eq 'active'
    end

    it 'end_date が nil の MasterLease は更新しない' do
      ml = create(:master_lease, status: :active, end_date: nil)

      described_class.perform_now

      expect(ml.reload.status).to eq 'active'
    end

    it '更新件数を返す' do
      create(:master_lease, status: :active, end_date: 3.days.ago.to_date)
      create(:master_lease, status: :active, end_date: 1.month.from_now.to_date)

      result = described_class.perform_now

      expect(result).to eq 1
    end
  end
end
