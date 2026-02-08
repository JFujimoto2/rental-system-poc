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

  describe '.search' do
    let!(:tenant1) { create(:tenant, name: "佐藤太郎") }
    let!(:tenant2) { create(:tenant, name: "高橋花子") }
    let!(:room1) { create(:room) }
    let!(:room2) { create(:room, room_number: "202") }
    let!(:contract1) { create(:contract, tenant: tenant1, room: room1) }
    let!(:contract2) { create(:contract, tenant: tenant2, room: room2) }
    let!(:tp1) { create(:tenant_payment, contract: contract1, status: :unpaid, payment_method: :transfer, due_date: Date.new(2024, 5, 1)) }
    let!(:tp2) { create(:tenant_payment, contract: contract2, status: :paid, payment_method: :cash, due_date: Date.new(2024, 7, 1)) }

    it '入居者名で部分一致検索できる' do
      result = TenantPayment.search({ tenant_name: "佐藤" })
      expect(result).to include(tp1)
      expect(result).not_to include(tp2)
    end

    it '状態で検索できる' do
      result = TenantPayment.search({ status: "paid" })
      expect(result).to include(tp2)
      expect(result).not_to include(tp1)
    end

    it '入金方法で検索できる' do
      result = TenantPayment.search({ payment_method: "transfer" })
      expect(result).to include(tp1)
      expect(result).not_to include(tp2)
    end

    it '期日の開始日で検索できる' do
      result = TenantPayment.search({ due_date_from: "2024-06-01" })
      expect(result).to include(tp2)
      expect(result).not_to include(tp1)
    end

    it '期日の終了日で検索できる' do
      result = TenantPayment.search({ due_date_to: "2024-06-01" })
      expect(result).to include(tp1)
      expect(result).not_to include(tp2)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = TenantPayment.search({})
      expect(result).to include(tp1, tp2)
    end
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
