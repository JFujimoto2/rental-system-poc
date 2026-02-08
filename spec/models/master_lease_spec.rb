require 'rails_helper'

RSpec.describe MasterLease do
  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:building) }
    it { is_expected.to have_many(:exemption_periods).dependent(:destroy) }
    it { is_expected.to have_many(:rent_revisions).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:contract_type) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:contract_type)
        .with_values(sublease: 0, management: 1, own: 2)
    }

    it {
      is_expected.to define_enum_for(:status)
        .with_values(active: 0, scheduled_termination: 1, terminated: 2)
    }
  end

  describe '.search' do
    let!(:owner1) { create(:owner, name: "オーナーA") }
    let!(:owner2) { create(:owner, name: "オーナーB") }
    let!(:building1) { create(:building, name: "Aビル", owner: owner1) }
    let!(:building2) { create(:building, name: "Bビル", owner: owner2) }
    let!(:ml1) { create(:master_lease, owner: owner1, building: building1, contract_type: :sublease, status: :active) }
    let!(:ml2) { create(:master_lease, owner: owner2, building: building2, contract_type: :management, status: :terminated) }

    it 'オーナーIDで検索できる' do
      result = MasterLease.search({ owner_id: owner1.id.to_s })
      expect(result).to include(ml1)
      expect(result).not_to include(ml2)
    end

    it '建物IDで検索できる' do
      result = MasterLease.search({ building_id: building2.id.to_s })
      expect(result).to include(ml2)
      expect(result).not_to include(ml1)
    end

    it '状態で検索できる' do
      result = MasterLease.search({ status: "active" })
      expect(result).to include(ml1)
      expect(result).not_to include(ml2)
    end

    it '契約形態で検索できる' do
      result = MasterLease.search({ contract_type: "management" })
      expect(result).to include(ml2)
      expect(result).not_to include(ml1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = MasterLease.search({})
      expect(result).to include(ml1, ml2)
    end
  end

  describe '#contract_type_label' do
    it 'サブリースの日本語ラベルを返す' do
      master_lease = build(:master_lease, contract_type: :sublease)
      expect(master_lease.contract_type_label).to eq 'サブリース'
    end

    it '管理委託の日本語ラベルを返す' do
      master_lease = build(:master_lease, contract_type: :management)
      expect(master_lease.contract_type_label).to eq '管理委託'
    end
  end

  describe '#status_label' do
    it '契約中の日本語ラベルを返す' do
      master_lease = build(:master_lease, status: :active)
      expect(master_lease.status_label).to eq '契約中'
    end
  end
end
