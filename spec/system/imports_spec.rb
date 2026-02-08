require 'rails_helper'

RSpec.describe 'Excelインポート', type: :system do
  it '建物データをExcelからインポートできる' do
    file_path = Rails.root.join('tmp/test_system_buildings.xlsx')
    generate_building_xlsx(file_path)

    visit new_import_path

    select '建物', from: 'インポート種別'
    attach_file 'Excel ファイル (.xlsx)', file_path
    click_button 'プレビュー'

    expect(page).to have_content 'インポートプレビュー'
    expect(page).to have_content 'テストビルA'
    expect(page).to have_content 'テストビルB'
    expect(page).to have_content '正常: 2 件'

    click_button '2件をインポートする'

    expect(page).to have_content '2件のデータをインポートしました'
    expect(Building.count).to eq 2
  ensure
    FileUtils.rm_f(file_path)
  end

  it '部屋データをExcelからインポートできる' do
    create(:building, name: 'テストビルA')
    file_path = Rails.root.join('tmp/test_system_rooms.xlsx')
    generate_room_xlsx(file_path)

    visit new_import_path

    select '部屋', from: 'インポート種別'
    attach_file 'Excel ファイル (.xlsx)', file_path
    click_button 'プレビュー'

    expect(page).to have_content 'インポートプレビュー'
    expect(page).to have_content '101'
    expect(page).to have_content '102'

    click_button '2件をインポートする'

    expect(page).to have_content '2件のデータをインポートしました'
    expect(Room.count).to eq 2
  ensure
    FileUtils.rm_f(file_path)
  end

  it 'バリデーションエラーがプレビュー画面に表示される' do
    file_path = Rails.root.join('tmp/test_system_buildings_invalid.xlsx')
    generate_building_xlsx_with_errors(file_path)

    visit new_import_path

    select '建物', from: 'インポート種別'
    attach_file 'Excel ファイル (.xlsx)', file_path
    click_button 'プレビュー'

    expect(page).to have_content 'エラー'
    expect(page).to have_content '建物名は必須です'
    expect(page).to have_content '正常: 1 件'
    expect(page).to have_content 'エラー: 1 件'
  ensure
    FileUtils.rm_f(file_path)
  end

  private

  def generate_building_xlsx(path)
    require 'caxlsx'
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '建物') do |sheet|
      sheet.add_row %w[建物名 住所 構造 階数 築年 最寄駅 備考]
      sheet.add_row [ 'テストビルA', '東京都渋谷区1-1', 'RC', 5, 2010, '渋谷駅', '' ]
      sheet.add_row [ 'テストビルB', '東京都新宿区2-2', 'SRC', 10, 2015, '新宿駅', '' ]
    end
    package.serialize(path.to_s)
  end

  def generate_room_xlsx(path)
    require 'caxlsx'
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '部屋') do |sheet|
      sheet.add_row %w[建物名 部屋番号 階数 面積 賃料 間取り 状態 備考]
      sheet.add_row [ 'テストビルA', '101', 1, 25.5, 80_000, '1K', '空室', '' ]
      sheet.add_row [ 'テストビルA', '102', 1, 30.0, 90_000, '1DK', '空室', '' ]
    end
    package.serialize(path.to_s)
  end

  def generate_building_xlsx_with_errors(path)
    require 'caxlsx'
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: '建物') do |sheet|
      sheet.add_row %w[建物名 住所 構造 階数 築年 最寄駅 備考]
      sheet.add_row [ 'テストビルA', '東京都渋谷区1-1', 'RC', 5, 2010, '渋谷駅', '' ]
      sheet.add_row [ '', '東京都港区3-3', '木造', 2, 2020, '品川駅', '' ]
    end
    package.serialize(path.to_s)
  end
end
