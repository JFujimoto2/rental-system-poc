require 'rails_helper'

RSpec.describe MonthlyOwnerPaymentGenerationJob, type: :job do
  let!(:master_lease) { create(:master_lease, status: :active, guaranteed_rent: 200_000) }

  describe '#perform' do
    it 'active な MasterLease から翌月分の OwnerPayment を生成する' do
      expect { described_class.perform_now }
        .to change(OwnerPayment, :count).by(1)

      payment = OwnerPayment.last
      next_month = Date.current.next_month.beginning_of_month
      expect(payment.master_lease).to eq master_lease
      expect(payment.target_month).to eq next_month
      expect(payment.guaranteed_amount).to eq 200_000
      expect(payment.deduction).to eq 0
      expect(payment.net_amount).to eq 200_000
      expect(payment.status).to eq 'unpaid'
    end

    it '既に翌月分がある場合はスキップする（冪等性）' do
      described_class.perform_now

      expect { described_class.perform_now }
        .not_to change(OwnerPayment, :count)
    end

    it 'terminated な MasterLease からは生成しない' do
      master_lease.update!(status: :terminated)

      expect { described_class.perform_now }
        .not_to change(OwnerPayment, :count)
    end

    it '生成件数を返す' do
      create(:master_lease, status: :active, guaranteed_rent: 150_000)

      result = described_class.perform_now

      expect(result).to eq 2
    end
  end
end
