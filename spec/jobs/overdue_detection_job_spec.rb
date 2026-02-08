require 'rails_helper'

RSpec.describe OverdueDetectionJob, type: :job do
  let!(:contract) { create(:contract) }

  describe '#perform' do
    it '期日超過の未入金を overdue に更新する' do
      payment = create(:tenant_payment, contract: contract,
                       due_date: 3.days.ago.to_date, status: :unpaid)

      described_class.perform_now

      expect(payment.reload.status).to eq 'overdue'
    end

    it '期日前の未入金は更新しない' do
      payment = create(:tenant_payment, contract: contract,
                       due_date: 3.days.from_now.to_date, status: :unpaid)

      described_class.perform_now

      expect(payment.reload.status).to eq 'unpaid'
    end

    it '当日期日の未入金は更新しない' do
      payment = create(:tenant_payment, contract: contract,
                       due_date: Date.current, status: :unpaid)

      described_class.perform_now

      expect(payment.reload.status).to eq 'unpaid'
    end

    it '既に overdue のレコードは影響を受けない' do
      payment = create(:tenant_payment, contract: contract,
                       due_date: 10.days.ago.to_date, status: :overdue)

      described_class.perform_now

      expect(payment.reload.status).to eq 'overdue'
    end

    it 'paid のレコードは影響を受けない' do
      payment = create(:tenant_payment, contract: contract,
                       due_date: 3.days.ago.to_date, status: :paid,
                       paid_amount: 100_000)

      described_class.perform_now

      expect(payment.reload.status).to eq 'paid'
    end

    it '更新件数を返す' do
      create(:tenant_payment, contract: contract, due_date: 5.days.ago.to_date, status: :unpaid)
      create(:tenant_payment, contract: contract, due_date: 2.days.ago.to_date, status: :unpaid)
      create(:tenant_payment, contract: contract, due_date: 3.days.from_now.to_date, status: :unpaid)

      result = described_class.perform_now

      expect(result).to eq 2
    end
  end
end
