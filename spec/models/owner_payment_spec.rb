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
