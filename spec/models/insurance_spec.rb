require 'rails_helper'

RSpec.describe Insurance do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:insurance_type) }
    it { is_expected.to validate_presence_of(:status) }

    it '建物か部屋のいずれかが必須' do
      insurance = build(:insurance, building: nil, room: nil)
      expect(insurance).not_to be_valid
      expect(insurance.errors[:base]).to include("建物または部屋のいずれかを指定してください")
    end

    it '建物のみ指定で有効' do
      insurance = build(:insurance, building: create(:building), room: nil)
      expect(insurance).to be_valid
    end

    it '部屋のみ指定で有効' do
      insurance = build(:insurance, building: nil, room: create(:room))
      expect(insurance).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:building).optional }
    it { is_expected.to belong_to(:room).optional }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:insurance_type).with_values(fire: 0, earthquake: 1, tenant_liability: 2, facility_liability: 3, other: 4) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, expiring_soon: 1, expired: 2, cancelled: 3) }
  end

  describe '.search' do
    let!(:building1) { create(:building, name: "テストマンション") }
    let!(:building2) { create(:building, name: "サンプルビル") }
    let!(:insurance1) { create(:insurance, building: building1, insurance_type: :fire, status: :active, provider: "東京海上") }
    let!(:insurance2) { create(:insurance, building: building2, insurance_type: :earthquake, status: :expired, provider: "損保ジャパン") }

    it '建物名で検索できる' do
      result = Insurance.search({ building_name: "テスト" })
      expect(result).to include(insurance1)
      expect(result).not_to include(insurance2)
    end

    it '保険種別で検索できる' do
      result = Insurance.search({ insurance_type: "fire" })
      expect(result).to include(insurance1)
      expect(result).not_to include(insurance2)
    end

    it '状態で検索できる' do
      result = Insurance.search({ status: "expired" })
      expect(result).to include(insurance2)
      expect(result).not_to include(insurance1)
    end

    it '保険会社名で検索できる' do
      result = Insurance.search({ provider: "損保" })
      expect(result).to include(insurance2)
      expect(result).not_to include(insurance1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Insurance.search({})
      expect(result).to include(insurance1, insurance2)
    end
  end

  describe 'label methods' do
    let(:insurance) { build(:insurance, insurance_type: :fire, status: :active) }

    it 'insurance_type_label を返す' do
      expect(insurance.insurance_type_label).to eq "火災保険"
    end

    it 'status_label を返す' do
      expect(insurance.status_label).to eq "有効"
    end
  end
end
