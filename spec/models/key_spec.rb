require 'rails_helper'

RSpec.describe Key do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:key_type) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:key_histories).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:key_type).with_values(main: 0, duplicate: 1, spare: 2, mailbox: 3, auto_lock: 4) }
    it { is_expected.to define_enum_for(:status).with_values(in_stock: 0, issued: 1, lost: 2, disposed: 3) }
  end

  describe '.search' do
    let!(:building1) { create(:building, name: "テストマンション") }
    let!(:building2) { create(:building, name: "サンプルビル") }
    let!(:room1) { create(:room, building: building1, room_number: "101") }
    let!(:room2) { create(:room, building: building2, room_number: "201") }
    let!(:key1) { create(:key, room: room1, key_type: :main, status: :in_stock) }
    let!(:key2) { create(:key, room: room2, key_type: :duplicate, status: :issued, key_number: "K-002") }

    it '建物名で検索できる' do
      result = Key.search({ building_name: "テスト" })
      expect(result).to include(key1)
      expect(result).not_to include(key2)
    end

    it '部屋番号で検索できる' do
      result = Key.search({ room_number: "201" })
      expect(result).to include(key2)
      expect(result).not_to include(key1)
    end

    it '鍵種別で検索できる' do
      result = Key.search({ key_type: "main" })
      expect(result).to include(key1)
      expect(result).not_to include(key2)
    end

    it '状態で検索できる' do
      result = Key.search({ status: "issued" })
      expect(result).to include(key2)
      expect(result).not_to include(key1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Key.search({})
      expect(result).to include(key1, key2)
    end
  end

  describe 'label methods' do
    let(:key) { build(:key, key_type: :main, status: :in_stock) }

    it 'key_type_label を返す' do
      expect(key.key_type_label).to eq "本鍵"
    end

    it 'status_label を返す' do
      expect(key.status_label).to eq "在庫"
    end
  end
end
