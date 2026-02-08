require 'rails_helper'

RSpec.describe '工事管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:vendor) { create(:vendor, name: 'テスト工務店') }

  it '工事を新規作成して詳細画面に遷移する' do
    visit constructions_path
    click_link '新規工事登録'

    select 'テストビル 101', from: '部屋'
    select 'テスト工務店', from: '業者'
    fill_in '工事件名', with: '退去後原状回復'
    select '原状回復', from: '工事種別'
    select '下書き', from: '状態'
    fill_in '見積金額', with: '500000'
    click_button '登録する'

    expect(page).to have_content '工事を登録しました'
    expect(page).to have_content '退去後原状回復'
  end

  it '工事一覧から詳細画面に遷移できる' do
    create(:construction, room: room, vendor: vendor, title: '表示テスト工事')
    visit constructions_path

    click_link '表示テスト工事'

    expect(page).to have_content '表示テスト工事'
  end

  it '工事を編集できる' do
    construction = create(:construction, room: room, title: '編集前工事')
    visit construction_path(construction)

    click_link '編集'
    fill_in '工事件名', with: '編集後工事'
    click_button '更新する'

    expect(page).to have_content '編集後工事'
    expect(page).to have_content '工事を更新しました'
  end

  it '部屋詳細画面から工事を追加できる' do
    visit room_path(room)

    expect(page).to have_content '工事履歴'
    click_link 'この部屋に工事を追加'

    expect(page).to have_content '工事登録'
  end
end
