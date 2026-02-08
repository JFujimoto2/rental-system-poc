require 'rails_helper'

RSpec.describe InsuranceExpirationJob do
  describe '#perform' do
    let!(:expiring_insurance) do
      create(:insurance, status: :active, end_date: 15.days.from_now.to_date)
    end
    let!(:not_expiring_insurance) do
      create(:insurance, status: :active, end_date: 60.days.from_now.to_date)
    end
    let!(:already_expiring_soon) do
      create(:insurance, status: :expiring_soon, end_date: 10.days.from_now.to_date)
    end

    it '30日以内に期限が来るactive保険をexpiring_soonに更新する' do
      count = described_class.new.perform
      expect(count).to eq 1
      expect(expiring_insurance.reload.status).to eq "expiring_soon"
    end

    it '30日以上先の保険はactiveのまま' do
      described_class.new.perform
      expect(not_expiring_insurance.reload.status).to eq "active"
    end

    it '既にexpiring_soonの保険は対象外' do
      described_class.new.perform
      expect(already_expiring_soon.reload.status).to eq "expiring_soon"
    end
  end
end
