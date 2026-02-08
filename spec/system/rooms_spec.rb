require 'rails_helper'

RSpec.describe '部屋管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }

  it '部屋を新規作成して詳細画面に遷移する' do
    visit new_room_path

    select 'テストビル', from: '建物'
    fill_in '部屋番号', with: '201'
    fill_in '階数', with: '2'
    fill_in '間取り', with: '1LDK'
    click_button '登録する'

    expect(page).to have_content '201'
    expect(page).to have_content '部屋を登録しました'
  end

  it '部屋一覧から詳細画面に遷移できる' do
    create(:room, building: building, room_number: '301')
    visit rooms_path

    click_link '301'

    expect(page).to have_content 'テストビル'
    expect(page).to have_content '301'
  end

  it '部屋を編集できる' do
    room = create(:room, building: building, room_number: '401')
    visit room_path(room)

    click_link '編集'
    fill_in '部屋番号', with: '401A'
    click_button '更新する'

    expect(page).to have_content '401A'
    expect(page).to have_content '部屋を更新しました'
  end

  it '建物詳細から部屋を追加できる' do
    visit building_path(building)

    click_link 'この建物に部屋を追加'
    fill_in '部屋番号', with: '501'
    click_button '登録する'

    expect(page).to have_content '501'
  end
end
