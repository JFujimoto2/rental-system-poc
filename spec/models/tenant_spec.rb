require 'rails_helper'

RSpec.describe Tenant do
  describe 'associations' do
    it { is_expected.to have_many(:contracts) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '.search' do
    let!(:tenant1) { create(:tenant, name: "佐藤太郎", name_kana: "サトウタロウ", phone: "090-1111-1111") }
    let!(:tenant2) { create(:tenant, name: "高橋花子", name_kana: "タカハシハナコ", phone: "080-2222-2222") }

    it '名前で部分一致検索できる' do
      result = Tenant.search({ name: "佐藤" })
      expect(result).to include(tenant1)
      expect(result).not_to include(tenant2)
    end

    it 'カナで部分一致検索できる' do
      result = Tenant.search({ name_kana: "タカハシ" })
      expect(result).to include(tenant2)
      expect(result).not_to include(tenant1)
    end

    it '電話番号で部分一致検索できる' do
      result = Tenant.search({ phone: "090" })
      expect(result).to include(tenant1)
      expect(result).not_to include(tenant2)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Tenant.search({})
      expect(result).to include(tenant1, tenant2)
    end
  end
end
