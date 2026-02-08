require 'rails_helper'

RSpec.describe OwnerPayment do
  describe 'associations' do
    it { is_expected.to belong_to(:master_lease) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:target_month) }
    it { is_expected.to validate_presence_of(:guaranteed_amount) }
    it { is_expected.to validate_presence_of(:net_amount) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(unpaid: 0, paid: 1)
    }
  end

  describe '.search' do
    let!(:owner1) { create(:owner, name: "オーナーA") }
    let!(:owner2) { create(:owner, name: "オーナーB") }
    let!(:building1) { create(:building, name: "Aビル", owner: owner1) }
    let!(:building2) { create(:building, name: "Bビル", owner: owner2) }
    let!(:ml1) { create(:master_lease, owner: owner1, building: building1) }
    let!(:ml2) { create(:master_lease, owner: owner2, building: building2) }
    let!(:op1) { create(:owner_payment, master_lease: ml1, status: :unpaid, target_month: Date.new(2024, 5, 1)) }
    let!(:op2) { create(:owner_payment, master_lease: ml2, status: :paid, target_month: Date.new(2024, 8, 1)) }

    it 'オーナー名で部分一致検索できる' do
      result = OwnerPayment.search({ owner_name: "オーナーA" })
      expect(result).to include(op1)
      expect(result).not_to include(op2)
    end

    it '建物名で部分一致検索できる' do
      result = OwnerPayment.search({ building_name: "Bビル" })
      expect(result).to include(op2)
      expect(result).not_to include(op1)
    end

    it '状態で検索できる' do
      result = OwnerPayment.search({ status: "paid" })
      expect(result).to include(op2)
      expect(result).not_to include(op1)
    end

    it '対象月の開始日で検索できる' do
      result = OwnerPayment.search({ target_month_from: "2024-07-01" })
      expect(result).to include(op2)
      expect(result).not_to include(op1)
    end

    it '対象月の終了日で検索できる' do
      result = OwnerPayment.search({ target_month_to: "2024-06-01" })
      expect(result).to include(op1)
      expect(result).not_to include(op2)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = OwnerPayment.search({})
      expect(result).to include(op1, op2)
    end
  end

  describe '#status_label' do
    it '未払の日本語ラベルを返す' do
      op = build(:owner_payment, status: :unpaid)
      expect(op.status_label).to eq '未払'
    end

    it '支払済の日本語ラベルを返す' do
      op = build(:owner_payment, status: :paid)
      expect(op.status_label).to eq '支払済'
    end
  end
end
