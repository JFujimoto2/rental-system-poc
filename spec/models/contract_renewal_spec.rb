require 'rails_helper'

RSpec.describe ContractRenewal do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:contract) }
    it { is_expected.to belong_to(:new_contract).class_name("Contract").optional }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, notified: 1, negotiating: 2, agreed: 3, renewed: 4, declined: 5, cancelled: 6) }
  end

  describe '.search' do
    let!(:building1) { create(:building, name: "テストマンション") }
    let!(:building2) { create(:building, name: "サンプルビル") }
    let!(:room1) { create(:room, building: building1) }
    let!(:room2) { create(:room, building: building2, room_number: "201") }
    let!(:tenant1) { create(:tenant, name: "田中太郎") }
    let!(:tenant2) { create(:tenant, name: "佐藤花子") }
    let!(:contract1) { create(:contract, room: room1, tenant: tenant1) }
    let!(:contract2) { create(:contract, room: room2, tenant: tenant2) }
    let!(:renewal1) { create(:contract_renewal, contract: contract1, status: :pending) }
    let!(:renewal2) { create(:contract_renewal, contract: contract2, status: :agreed) }

    it '建物名で検索できる' do
      result = ContractRenewal.search({ building_name: "テスト" })
      expect(result).to include(renewal1)
      expect(result).not_to include(renewal2)
    end

    it '入居者名で検索できる' do
      result = ContractRenewal.search({ tenant_name: "佐藤" })
      expect(result).to include(renewal2)
      expect(result).not_to include(renewal1)
    end

    it '状態で検索できる' do
      result = ContractRenewal.search({ status: "agreed" })
      expect(result).to include(renewal2)
      expect(result).not_to include(renewal1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = ContractRenewal.search({})
      expect(result).to include(renewal1, renewal2)
    end
  end

  describe 'label methods' do
    let(:renewal) { build(:contract_renewal, status: :pending) }

    it 'status_label を返す' do
      expect(renewal.status_label).to eq "未着手"
    end
  end
end
