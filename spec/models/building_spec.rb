require 'rails_helper'

RSpec.describe Building do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:rooms).dependent(:destroy) }
  end

  describe '.search' do
    let!(:owner1) { create(:owner, name: "オーナーA") }
    let!(:owner2) { create(:owner, name: "オーナーB") }
    let!(:building1) { create(:building, name: "サンプルマンション", address: "東京都渋谷区", building_type: "RC", owner: owner1) }
    let!(:building2) { create(:building, name: "テストビル", address: "大阪府大阪市", building_type: "SRC", owner: owner2) }

    it '名前で部分一致検索できる' do
      result = Building.search({ name: "サンプル" })
      expect(result).to include(building1)
      expect(result).not_to include(building2)
    end

    it '住所で部分一致検索できる' do
      result = Building.search({ address: "大阪" })
      expect(result).to include(building2)
      expect(result).not_to include(building1)
    end

    it 'オーナーIDで検索できる' do
      result = Building.search({ owner_id: owner1.id.to_s })
      expect(result).to include(building1)
      expect(result).not_to include(building2)
    end

    it '構造で部分一致検索できる' do
      result = Building.search({ building_type: "SRC" })
      expect(result).to include(building2)
      expect(result).not_to include(building1)
    end

    it '複数条件をANDで結合する' do
      result = Building.search({ name: "サンプル", address: "渋谷" })
      expect(result).to include(building1)
      expect(result).not_to include(building2)
    end

    it 'パラメータが空の場合は全件を返す' do
      result = Building.search({})
      expect(result).to include(building1, building2)
    end
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
