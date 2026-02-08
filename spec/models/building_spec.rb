require 'rails_helper'

RSpec.describe Building do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:rooms).dependent(:destroy) }
  end

  describe 'dependent destroy' do
    it '建物を削除すると紐づく部屋も削除される' do
      building = create(:building)
      create(:room, building: building)
      create(:room, building: building, room_number: "102")

      expect { building.destroy }.to change(Room, :count).by(-2)
    end
  end
end
