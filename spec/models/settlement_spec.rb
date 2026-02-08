require 'rails_helper'

RSpec.describe Settlement, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:contract) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:settlement_type) }
    it { is_expected.to validate_presence_of(:termination_date) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:settlement_type)
        .with_values(tenant_rent: 0, tenant_deposit: 1)
    }
    it {
      is_expected.to define_enum_for(:status)
        .with_values(draft: 0, confirmed: 1, paid: 2)
    }
  end

  describe '#calculate_prorated_rent' do
    let(:building) { create(:building) }
    let(:room) { create(:room, building: building) }
    let(:tenant) { create(:tenant) }
    let(:contract) { create(:contract, room: room, tenant: tenant, rent: 150_000) }
    let(:settlement) do
      build(:settlement, contract: contract, settlement_type: :tenant_rent,
            termination_date: Date.new(2024, 6, 15))
    end

    it '日割り賃料を計算する' do
      settlement.calculate_prorated_rent
      # 6月は30日、15日分
      expect(settlement.daily_rent).to eq(5_000)   # 150,000 / 30
      expect(settlement.days_count).to eq(15)       # 1日〜15日
      expect(settlement.prorated_rent).to eq(75_000) # 5,000 * 15
    end
  end

  describe '#calculate_deposit_refund' do
    let(:building) { create(:building) }
    let(:room) { create(:room, building: building) }
    let(:tenant) { create(:tenant) }
    let(:contract) { create(:contract, room: room, tenant: tenant, deposit: 300_000) }
    let(:settlement) do
      build(:settlement, contract: contract, settlement_type: :tenant_deposit,
            termination_date: Date.new(2024, 6, 30),
            deposit_amount: 300_000, restoration_cost: 80_000, other_deductions: 20_000)
    end

    it '敷金返還額を計算する' do
      settlement.calculate_deposit_refund
      expect(settlement.refund_amount).to eq(200_000) # 300,000 - 80,000 - 20,000
    end
  end

  describe '#calculate_deposit_refund（控除額が敷金を上回る場合）' do
    let(:building) { create(:building) }
    let(:room) { create(:room, building: building) }
    let(:tenant) { create(:tenant) }
    let(:contract) { create(:contract, room: room, tenant: tenant, deposit: 100_000) }
    let(:settlement) do
      build(:settlement, contract: contract, settlement_type: :tenant_deposit,
            termination_date: Date.new(2024, 6, 30),
            deposit_amount: 100_000, restoration_cost: 150_000, other_deductions: 0)
    end

    it '返還額がマイナスになる（追加請求）' do
      settlement.calculate_deposit_refund
      expect(settlement.refund_amount).to eq(-50_000)
    end
  end
end
