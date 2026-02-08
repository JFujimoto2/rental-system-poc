require 'rails_helper'

RSpec.describe Construction do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:construction_type) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:vendor).optional }
    it { is_expected.to have_many(:approvals) }
    it { is_expected.to have_many(:inquiries) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:construction_type).with_values(restoration: 0, renovation: 1, repair: 2, equipment: 3, other: 4) }
    it { is_expected.to define_enum_for(:status).with_values(draft: 0, ordered: 1, in_progress: 2, completed: 3, invoiced: 4, cancelled: 5) }
    it { is_expected.to define_enum_for(:cost_bearer).with_values(company: 0, owner: 1, tenant: 2) }
  end

  describe '.search' do
    let!(:building1) { create(:building, name: "テストマンション") }
    let!(:building2) { create(:building, name: "サンプルビル") }
    let!(:room1) { create(:room, building: building1) }
    let!(:room2) { create(:room, building: building2, room_number: "201") }
    let!(:vendor1) { create(:vendor, name: "ABC工務店") }
    let!(:vendor2) { create(:vendor, name: "DEF設備") }
    let!(:construction1) { create(:construction, room: room1, vendor: vendor1, construction_type: :restoration, status: :draft, cost_bearer: :company) }
    let!(:construction2) { create(:construction, room: room2, vendor: vendor2, construction_type: :renovation, status: :completed, cost_bearer: :owner, title: "リノベーション工事") }

    it '建物名で検索できる' do
      result = Construction.search({ building_name: "テスト" })
      expect(result).to include(construction1)
      expect(result).not_to include(construction2)
    end

    it '業者名で検索できる' do
      result = Construction.search({ vendor_name: "DEF" })
      expect(result).to include(construction2)
      expect(result).not_to include(construction1)
    end

    it '工事種別で検索できる' do
      result = Construction.search({ construction_type: "restoration" })
      expect(result).to include(construction1)
      expect(result).not_to include(construction2)
    end

    it '状態で検索できる' do
      result = Construction.search({ status: "completed" })
      expect(result).to include(construction2)
      expect(result).not_to include(construction1)
    end

    it '費用負担で検索できる' do
      result = Construction.search({ cost_bearer: "owner" })
      expect(result).to include(construction2)
      expect(result).not_to include(construction1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Construction.search({})
      expect(result).to include(construction1, construction2)
    end
  end

  describe 'label methods' do
    let(:construction) { build(:construction, construction_type: :restoration, status: :draft, cost_bearer: :company) }

    it 'construction_type_label を返す' do
      expect(construction.construction_type_label).to eq "原状回復"
    end

    it 'status_label を返す' do
      expect(construction.status_label).to eq "下書き"
    end

    it 'cost_bearer_label を返す' do
      expect(construction.cost_bearer_label).to eq "自社負担"
    end
  end
end
