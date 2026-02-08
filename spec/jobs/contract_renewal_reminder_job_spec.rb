require 'rails_helper'

RSpec.describe ContractRenewalReminderJob do
  describe '#perform' do
    let!(:active_contract_expiring) do
      create(:contract, status: :active, end_date: 2.months.from_now.to_date, rent: 80000)
    end
    let!(:active_contract_not_expiring) do
      create(:contract, status: :active, end_date: 6.months.from_now.to_date)
    end
    let!(:terminated_contract) do
      create(:contract, status: :terminated, end_date: 1.month.from_now.to_date)
    end

    it '3ヶ月以内に期限が来るactive契約に対して更新リマインダーを作成する' do
      expect {
        described_class.new.perform
      }.to change(ContractRenewal, :count).by(1)

      renewal = ContractRenewal.last
      expect(renewal.contract).to eq active_contract_expiring
      expect(renewal.status).to eq "pending"
      expect(renewal.current_rent).to eq 80000
    end

    it '既にContractRenewalが存在する契約はスキップする' do
      create(:contract_renewal, contract: active_contract_expiring)

      expect {
        described_class.new.perform
      }.not_to change(ContractRenewal, :count)
    end

    it 'terminated契約は対象外' do
      described_class.new.perform
      expect(ContractRenewal.where(contract: terminated_contract)).to be_empty
    end
  end
end
