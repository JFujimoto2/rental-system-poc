require 'rails_helper'

RSpec.describe 'オーナー管理', type: :system do
  it 'オーナーを新規作成して詳細画面に遷移する' do
    visit owners_path
    click_link '新規オーナー登録'

    fill_in 'オーナー名', with: 'テストオーナー'
    fill_in 'オーナー名カナ', with: 'テストオーナー'
    fill_in '電話番号', with: '03-1234-5678'
    click_button '登録する'

    expect(page).to have_content 'テストオーナー'
    expect(page).to have_content 'オーナーを登録しました'
  end

  it 'オーナー一覧から詳細画面に遷移できる' do
    create(:owner, name: '表示テストオーナー')
    visit owners_path

    click_link '表示テストオーナー'

    expect(page).to have_content '表示テストオーナー'
  end

  it 'オーナーを編集できる' do
    owner = create(:owner, name: '編集前オーナー')
    visit owner_path(owner)

    click_link '編集'
    fill_in 'オーナー名', with: '編集後オーナー'
    click_button '更新する'

    expect(page).to have_content '編集後オーナー'
    expect(page).to have_content 'オーナーを更新しました'
  end

  it '詳細画面に所有建物が表示される' do
    owner = create(:owner, name: '建物持ちオーナー')
    create(:building, owner: owner, name: '所有ビルA')

    visit owner_path(owner)

    expect(page).to have_content '所有建物'
    expect(page).to have_content '所有ビルA'
  end

  it '詳細画面にマスターリース契約が表示される' do
    owner = create(:owner, name: '契約持ちオーナー')
    building = create(:building, owner: owner, name: '契約ビル')
    create(:master_lease, owner: owner, building: building)

    visit owner_path(owner)

    expect(page).to have_content 'マスターリース契約'
    expect(page).to have_content '契約ビル'
  end
end
