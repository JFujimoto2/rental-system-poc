require 'rails_helper'

RSpec.describe '鍵管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }

  it '鍵を新規作成して詳細画面に遷移する' do
    visit keys_path
    click_link '新規鍵登録'

    select 'テストビル 101', from: '部屋'
    select '本鍵', from: '鍵種別'
    fill_in '鍵番号', with: 'KEY-001'
    select '在庫', from: '状態'
    click_button '登録する'

    expect(page).to have_content '鍵を登録しました'
    expect(page).to have_content 'KEY-001'
  end

  it '鍵一覧から詳細画面に遷移できる' do
    create(:key, room: room, key_type: :main, key_number: 'KEY-002', status: :in_stock)
    visit keys_path

    click_link '在庫'

    expect(page).to have_content 'KEY-002'
  end

  it '部屋詳細画面から鍵を追加できる' do
    visit room_path(room)

    expect(page).to have_content '鍵一覧'
    click_link 'この部屋に鍵を追加'

    expect(page).to have_content '鍵登録'
  end
end
