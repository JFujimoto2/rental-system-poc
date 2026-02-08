require 'rails_helper'

RSpec.describe '建物管理', type: :system do
  let!(:owner) { create(:owner) }

  it '建物を新規作成して詳細画面に遷移する' do
    visit buildings_path
    click_link '新規建物登録'

    fill_in '建物名', with: 'テストマンション'
    fill_in '住所', with: '東京都新宿区1-1-1'
    fill_in '構造', with: 'RC'
    fill_in '階数', with: '5'
    click_button '登録する'

    expect(page).to have_content 'テストマンション'
    expect(page).to have_content '建物を登録しました'
  end

  it '建物一覧から詳細画面に遷移できる' do
    create(:building, name: '表示テストビル')
    visit buildings_path

    click_link '表示テストビル'

    expect(page).to have_content '表示テストビル'
  end

  it '建物を編集できる' do
    building = create(:building, name: '編集前ビル')
    visit building_path(building)

    click_link '編集'
    fill_in '建物名', with: '編集後ビル'
    click_button '更新する'

    expect(page).to have_content '編集後ビル'
    expect(page).to have_content '建物を更新しました'
  end

  it '建物を削除できる' do
    create(:building, name: '削除対象ビル')
    visit buildings_path

    expect(page).to have_content '削除対象ビル'

    click_link '削除対象ビル'
    accept_confirm { click_button '削除' }

    expect(page).not_to have_content '削除対象ビル'
  end

  it '詳細画面に部屋一覧が表示される' do
    building = create(:building, name: '部屋付きビル')
    create(:room, building: building, room_number: '101')

    visit building_path(building)

    expect(page).to have_content '部屋一覧'
    expect(page).to have_content '101'
  end
end
