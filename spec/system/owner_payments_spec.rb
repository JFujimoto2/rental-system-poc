require 'rails_helper'

RSpec.describe 'オーナー支払管理', type: :system do
  let!(:owner) { create(:owner, name: 'テストオーナー') }
  let!(:building) { create(:building, name: 'テストビル', owner: owner) }
  let!(:master_lease) { create(:master_lease, owner: owner, building: building) }

  it 'オーナー支払を新規作成して詳細画面に遷移する' do
    visit owner_payments_path
    click_link '新規オーナー支払登録'

    select 'テストビル（テストオーナー）', from: 'マスターリース契約'
    fill_in '対象月', with: '2024-06-01'
    fill_in '保証賃料額', with: '500000'
    fill_in '控除額', with: '0'
    fill_in '支払額', with: '500000'
    select '未払', from: '状態'
    click_button '登録する'

    expect(page).to have_content 'オーナー支払を登録しました'
    expect(page).to have_content 'テストオーナー'
    expect(page).to have_content '500,000'
  end

  it 'オーナー支払一覧から詳細画面に遷移できる' do
    create(:owner_payment, master_lease: master_lease)
    visit owner_payments_path

    click_link '詳細'

    expect(page).to have_content 'テストオーナー'
    expect(page).to have_content 'オーナー支払詳細'
  end

  it 'オーナー支払を編集して支払処理できる' do
    op = create(:owner_payment, master_lease: master_lease)
    visit owner_payment_path(op)

    click_link '編集'
    fill_in '支払日', with: '2024-05-31'
    select '支払済', from: '状態'
    click_button '更新する'

    expect(page).to have_content 'オーナー支払を更新しました'
    expect(page).to have_content '支払済'
  end

  it 'マスターリース詳細画面にオーナー支払履歴が表示される' do
    create(:owner_payment, master_lease: master_lease)
    visit master_lease_path(master_lease)

    expect(page).to have_content 'オーナー支払履歴'
    expect(page).to have_content '未払'
  end
end
