require 'rails_helper'

RSpec.describe '転貸借契約管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }

  it '契約を新規作成して詳細画面に遷移する' do
    visit contracts_path
    click_link '新規契約登録'

    select 'テストビル - 101', from: '部屋'
    select 'テスト太郎', from: '入居者'
    select '普通借家', from: '借家種別'
    fill_in '契約開始日', with: '2024-04-01'
    fill_in '契約終了日', with: '2026-03-31'
    fill_in '月額賃料', with: '85000'
    fill_in '管理費', with: '5000'
    select '契約中', from: '状態'
    click_button '登録する'

    expect(page).to have_content '契約を登録しました'
    expect(page).to have_content 'テストビル'
    expect(page).to have_content '101'
    expect(page).to have_content 'テスト太郎'
  end

  it '契約一覧から詳細画面に遷移できる' do
    create(:contract, room: room, tenant: tenant, status: :active)
    visit contracts_path

    click_link '詳細'

    expect(page).to have_content 'テストビル'
    expect(page).to have_content '101'
    expect(page).to have_content 'テスト太郎'
  end

  it '契約を編集できる' do
    contract = create(:contract, room: room, tenant: tenant, rent: 85_000)
    visit contract_path(contract)

    click_link '編集'
    fill_in '月額賃料', with: '90000'
    click_button '更新する'

    expect(page).to have_content '契約を更新しました'
    expect(page).to have_content '90,000'
  end

  it '部屋詳細画面に契約履歴が表示される' do
    create(:contract, room: room, tenant: tenant, status: :active)

    visit room_path(room)

    expect(page).to have_content '契約履歴'
    expect(page).to have_content 'テスト太郎'
  end
end
