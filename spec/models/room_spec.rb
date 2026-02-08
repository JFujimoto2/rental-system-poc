require 'rails_helper'

RSpec.describe Room do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:room_number) }
    it { is_expected.to belong_to(:building) }
  end

  describe 'enum' do
    it { is_expected.to define_enum_for(:status).with_values(vacant: 0, occupied: 1, notice: 2) }
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
