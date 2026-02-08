require 'rails_helper'

RSpec.describe Room do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:room_number) }
    it { is_expected.to belong_to(:building) }
  end

  describe 'enum' do
    it { is_expected.to define_enum_for(:status).with_values(vacant: 0, occupied: 1, notice: 2) }
  end

  describe '.search' do
    let!(:building1) { create(:building, name: "Aマンション") }
    let!(:building2) { create(:building, name: "Bビル") }
    let!(:room1) { create(:room, building: building1, room_number: "101", status: :vacant, room_type: "1K") }
    let!(:room2) { create(:room, building: building2, room_number: "201", status: :occupied, room_type: "2LDK") }

    it '建物IDで検索できる' do
      result = Room.search({ building_id: building1.id.to_s })
      expect(result).to include(room1)
      expect(result).not_to include(room2)
    end

    it '部屋番号で部分一致検索できる' do
      result = Room.search({ room_number: "201" })
      expect(result).to include(room2)
      expect(result).not_to include(room1)
    end

    it '状態で検索できる' do
      result = Room.search({ status: "vacant" })
      expect(result).to include(room1)
      expect(result).not_to include(room2)
    end

    it '間取りで部分一致検索できる' do
      result = Room.search({ room_type: "2LDK" })
      expect(result).to include(room2)
      expect(result).not_to include(room1)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Room.search({})
      expect(result).to include(room1, room2)
    end
  end

  describe '#status_label' do
    it '空室の日本語ラベルを返す' do
      room = build(:room, status: :vacant)
      expect(room.status_label).to eq '空室'
    end

    it '入居中の日本語ラベルを返す' do
      room = build(:room, status: :occupied)
      expect(room.status_label).to eq '入居中'
    end

    it '退去予定の日本語ラベルを返す' do
      room = build(:room, status: :notice)
      expect(room.status_label).to eq '退去予定'
    end

    it 'status が nil の場合は nil を返す' do
      room = build(:room, status: nil)
      expect(room.status_label).to be_nil
    end
  end
end
