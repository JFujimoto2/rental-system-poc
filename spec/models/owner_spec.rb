require 'rails_helper'

RSpec.describe Owner do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:buildings) }
  end

  describe '.search' do
    let!(:owner1) { create(:owner, name: "田中太郎", phone: "03-1111-1111", email: "tanaka@example.com") }
    let!(:owner2) { create(:owner, name: "鈴木花子", phone: "06-2222-2222", email: "suzuki@example.com") }

    it '名前で部分一致検索できる' do
      result = Owner.search({ name: "田中" })
      expect(result).to include(owner1)
      expect(result).not_to include(owner2)
    end

    it '電話番号で部分一致検索できる' do
      result = Owner.search({ phone: "06" })
      expect(result).to include(owner2)
      expect(result).not_to include(owner1)
    end

    it 'メールで部分一致検索できる' do
      result = Owner.search({ email: "tanaka" })
      expect(result).to include(owner1)
      expect(result).not_to include(owner2)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Owner.search({})
      expect(result).to include(owner1, owner2)
    end
  end
end
