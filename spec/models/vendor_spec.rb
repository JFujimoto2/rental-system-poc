require 'rails_helper'

RSpec.describe Vendor do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:constructions) }
  end

  describe '.search' do
    let!(:vendor1) { create(:vendor, name: "ABC工務店", phone: "03-1111-2222") }
    let!(:vendor2) { create(:vendor, name: "DEF設備", phone: "06-3333-4444") }

    it '名前で部分一致検索できる' do
      result = Vendor.search({ name: "ABC" })
      expect(result).to include(vendor1)
      expect(result).not_to include(vendor2)
    end

    it '電話番号で部分一致検索できる' do
      result = Vendor.search({ phone: "06" })
      expect(result).to include(vendor2)
      expect(result).not_to include(vendor1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Vendor.search({})
      expect(result).to include(vendor1, vendor2)
    end
  end
end
