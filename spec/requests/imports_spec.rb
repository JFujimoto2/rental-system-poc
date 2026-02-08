require 'rails_helper'

RSpec.describe 'Imports' do
  describe 'GET /imports/new' do
    it 'アップロード画面を表示できる' do
      get new_import_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /imports/preview' do
    it '建物データをプレビューできる' do
      file = create_building_xlsx
      post preview_imports_path, params: {
        import: { file: file, import_type: 'building' }
      }
      expect(response).to have_http_status(:success)
    end

    it '部屋データをプレビューできる' do
      create(:building, name: 'テストビルA')
      file = create_room_xlsx
      post preview_imports_path, params: {
        import: { file: file, import_type: 'room' }
      }
      expect(response).to have_http_status(:success)
    end

    it 'ファイル未選択時はリダイレクトする' do
      post preview_imports_path, params: {
        import: { import_type: 'building' }
      }
      expect(response).to redirect_to(new_import_path)
    end
  end

  describe 'POST /imports' do
    it '建物データをインポートできる' do
      file = create_building_xlsx
      post preview_imports_path, params: {
        import: { file: file, import_type: 'building' }
      }

      expect {
        post imports_path, params: { import_type: 'building' }
      }.to change(Building, :count).by(2)
      expect(response).to redirect_to(buildings_path)
    end

    it '部屋データをインポートできる' do
      create(:building, name: 'テストビルA')
      file = create_room_xlsx
      post preview_imports_path, params: {
        import: { file: file, import_type: 'room' }
      }

      expect {
        post imports_path, params: { import_type: 'room' }
      }.to change(Room, :count).by(2)
      expect(response).to redirect_to(rooms_path)
    end
  end

  private

  def create_building_xlsx
    require 'caxlsx'
    path = Rails.root.join('tmp/test_buildings.xlsx')
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '建物') do |sheet|
      sheet.add_row %w[建物名 住所 構造 階数 築年 最寄駅 備考]
      sheet.add_row [ 'テストビルA', '東京都渋谷区1-1', 'RC', 5, 2010, '渋谷駅', '' ]
      sheet.add_row [ 'テストビルB', '東京都新宿区2-2', 'SRC', 10, 2015, '新宿駅', '' ]
    end
    package.serialize(path.to_s)
    Rack::Test::UploadedFile.new(path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  end

  def create_room_xlsx
    require 'caxlsx'
    path = Rails.root.join('tmp/test_rooms.xlsx')
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '部屋') do |sheet|
      sheet.add_row %w[建物名 部屋番号 階数 面積 賃料 間取り 状態 備考]
      sheet.add_row [ 'テストビルA', '101', 1, 25.5, 80_000, '1K', '空室', '' ]
      sheet.add_row [ 'テストビルA', '102', 1, 30.0, 90_000, '1DK', '空室', '' ]
    end
    package.serialize(path.to_s)
    Rack::Test::UploadedFile.new(path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  end
end
