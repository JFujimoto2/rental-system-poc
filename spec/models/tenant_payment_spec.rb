require 'rails_helper'

RSpec.describe TenantPayment do
  describe 'associations' do
    it { is_expected.to belong_to(:contract) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:due_date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(unpaid: 0, paid: 1, partial: 2, overdue: 3)
    }

    it {
      is_expected.to define_enum_for(:payment_method)
        .with_values(transfer: 0, direct_debit: 1, cash: 2)
    }
  end

  describe '#status_label' do
    it '未入金の日本語ラベルを返す' do
      tp = build(:tenant_payment, status: :unpaid)
      expect(tp.status_label).to eq '未入金'
    end

    it '入金済の日本語ラベルを返す' do
      tp = build(:tenant_payment, status: :paid)
      expect(tp.status_label).to eq '入金済'
    end
  end

  describe '#payment_method_label' do
    it '振込の日本語ラベルを返す' do
      tp = build(:tenant_payment, payment_method: :transfer)
      expect(tp.payment_method_label).to eq '振込'
    end
  end
end
