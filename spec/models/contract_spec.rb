require 'rails_helper'

RSpec.describe Contract do
  describe 'associations' do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to belong_to(:master_lease).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:lease_type) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:lease_type)
        .with_values(ordinary: 0, fixed_term: 1)
    }

    it {
      is_expected.to define_enum_for(:status)
        .with_values(applying: 0, active: 1, scheduled_termination: 2, terminated: 3)
    }
  end

  describe '.search' do
    let!(:building1) { create(:building, name: "Aマンション") }
    let!(:building2) { create(:building, name: "Bビル") }
    let!(:room1) { create(:room, building: building1) }
    let!(:room2) { create(:room, building: building2, room_number: "201") }
    let!(:tenant1) { create(:tenant, name: "佐藤太郎") }
    let!(:tenant2) { create(:tenant, name: "高橋花子") }
    let!(:contract1) { create(:contract, room: room1, tenant: tenant1, lease_type: :ordinary, status: :active) }
    let!(:contract2) { create(:contract, room: room2, tenant: tenant2, lease_type: :fixed_term, status: :terminated) }

    it '建物名で部分一致検索できる' do
      result = Contract.search({ building_name: "Aマンション" })
      expect(result).to include(contract1)
      expect(result).not_to include(contract2)
    end

    it '入居者名で部分一致検索できる' do
      result = Contract.search({ tenant_name: "高橋" })
      expect(result).to include(contract2)
      expect(result).not_to include(contract1)
    end

    it '状態で検索できる' do
      result = Contract.search({ status: "active" })
      expect(result).to include(contract1)
      expect(result).not_to include(contract2)
    end

    it '借家種別で検索できる' do
      result = Contract.search({ lease_type: "fixed_term" })
      expect(result).to include(contract2)
      expect(result).not_to include(contract1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Contract.search({})
      expect(result).to include(contract1, contract2)
    end
  end

  describe '#lease_type_label' do
    it '普通借家の日本語ラベルを返す' do
      contract = build(:contract, lease_type: :ordinary)
      expect(contract.lease_type_label).to eq '普通借家'
    end

    it '定期借家の日本語ラベルを返す' do
      contract = build(:contract, lease_type: :fixed_term)
      expect(contract.lease_type_label).to eq '定期借家'
    end
  end

  describe '#status_label' do
    it '契約中の日本語ラベルを返す' do
      contract = build(:contract, status: :active)
      expect(contract.status_label).to eq '契約中'
    end

    it '申込の日本語ラベルを返す' do
      contract = build(:contract, status: :applying)
      expect(contract.status_label).to eq '申込'
    end
  end
end
