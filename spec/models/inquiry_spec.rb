require 'rails_helper'

RSpec.describe Inquiry do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:room).optional }
    it { is_expected.to belong_to(:tenant).optional }
    it { is_expected.to belong_to(:assigned_user).class_name("User").optional }
    it { is_expected.to belong_to(:construction).optional }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:category).with_values(repair: 0, complaint: 1, question: 2, noise: 3, leak: 4, other: 5) }
    it { is_expected.to define_enum_for(:priority).with_values(low: 0, normal: 1, high: 2, urgent: 3) }
    it { is_expected.to define_enum_for(:status).with_values(received: 0, assigned: 1, in_progress: 2, completed: 3, closed: 4) }
  end

  describe '.search' do
    let!(:building) { create(:building, name: "テストマンション") }
    let!(:room) { create(:room, building: building) }
    let!(:tenant1) { create(:tenant, name: "田中太郎") }
    let!(:tenant2) { create(:tenant, name: "佐藤花子") }
    let!(:inquiry1) { create(:inquiry, room: room, tenant: tenant1, category: :repair, priority: :high, status: :received) }
    let!(:inquiry2) { create(:inquiry, tenant: tenant2, category: :complaint, priority: :low, status: :closed, title: "騒音苦情") }

    it '建物名で検索できる' do
      result = Inquiry.search({ building_name: "テスト" })
      expect(result).to include(inquiry1)
      expect(result).not_to include(inquiry2)
    end

    it '入居者名で検索できる' do
      result = Inquiry.search({ tenant_name: "佐藤" })
      expect(result).to include(inquiry2)
      expect(result).not_to include(inquiry1)
    end

    it 'カテゴリで検索できる' do
      result = Inquiry.search({ category: "repair" })
      expect(result).to include(inquiry1)
      expect(result).not_to include(inquiry2)
    end

    it '優先度で検索できる' do
      result = Inquiry.search({ priority: "high" })
      expect(result).to include(inquiry1)
      expect(result).not_to include(inquiry2)
    end

    it '状態で検索できる' do
      result = Inquiry.search({ status: "closed" })
      expect(result).to include(inquiry2)
      expect(result).not_to include(inquiry1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Inquiry.search({})
      expect(result).to include(inquiry1, inquiry2)
    end
  end

  describe 'label methods' do
    let(:inquiry) { build(:inquiry, category: :repair, priority: :normal, status: :received) }

    it 'category_label を返す' do
      expect(inquiry.category_label).to eq "修繕依頼"
    end

    it 'priority_label を返す' do
      expect(inquiry.priority_label).to eq "通常"
    end

    it 'status_label を返す' do
      expect(inquiry.status_label).to eq "受付"
    end
  end
end
