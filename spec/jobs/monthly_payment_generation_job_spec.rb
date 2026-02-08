require 'rails_helper'

RSpec.describe MonthlyPaymentGenerationJob, type: :job do
  let!(:contract) { create(:contract, status: :active, rent: 100_000) }

  describe '#perform' do
    it 'active な契約から翌月分の TenantPayment を生成する' do
      expect { described_class.perform_now }
        .to change(TenantPayment, :count).by(1)

      payment = TenantPayment.last
      next_month = Date.current.next_month.beginning_of_month
      expect(payment.contract).to eq contract
      expect(payment.due_date).to eq next_month
      expect(payment.amount).to eq 100_000
      expect(payment.status).to eq 'unpaid'
    end

    it '既に翌月分がある場合はスキップする（冪等性）' do
      described_class.perform_now

      expect { described_class.perform_now }
        .not_to change(TenantPayment, :count)
    end

    it 'terminated な契約からは生成しない' do
      contract.update!(status: :terminated)

      expect { described_class.perform_now }
        .not_to change(TenantPayment, :count)
    end

    it 'applying な契約からは生成しない' do
      contract.update!(status: :applying)

      expect { described_class.perform_now }
        .not_to change(TenantPayment, :count)
    end

    it '生成件数を返す' do
      create(:contract, status: :active, rent: 80_000)

      result = described_class.perform_now

      expect(result).to eq 2
    end
  end
end
