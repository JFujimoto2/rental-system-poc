require 'rails_helper'

RSpec.describe ContractExpirationJob, type: :job do
  describe '#perform' do
    it '解約予定で end_date 超過の契約を terminated に更新する' do
      contract = create(:contract, status: :scheduled_termination,
                        end_date: 1.day.ago.to_date)

      described_class.perform_now

      expect(contract.reload.status).to eq 'terminated'
    end

    it '解約予定で end_date 当日の契約は更新しない' do
      contract = create(:contract, status: :scheduled_termination,
                        end_date: Date.current)

      described_class.perform_now

      expect(contract.reload.status).to eq 'scheduled_termination'
    end

    it '解約予定で end_date が未来の契約は更新しない' do
      contract = create(:contract, status: :scheduled_termination,
                        end_date: 1.month.from_now.to_date)

      described_class.perform_now

      expect(contract.reload.status).to eq 'scheduled_termination'
    end

    it 'active な契約は更新しない' do
      contract = create(:contract, status: :active,
                        end_date: 1.day.ago.to_date)

      described_class.perform_now

      expect(contract.reload.status).to eq 'active'
    end

    it '更新件数を返す' do
      create(:contract, status: :scheduled_termination, end_date: 3.days.ago.to_date)
      create(:contract, status: :scheduled_termination, end_date: 1.day.ago.to_date)
      create(:contract, status: :scheduled_termination, end_date: 1.month.from_now.to_date)

      result = described_class.perform_now

      expect(result).to eq 2
    end
  end
end
