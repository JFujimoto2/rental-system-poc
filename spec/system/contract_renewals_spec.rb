require 'rails_helper'

RSpec.describe '契約更新管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 100_000, status: :active) }

  it '契約更新を新規作成して詳細画面に遷移する' do
    visit contract_renewals_path
    click_link '新規契約更新登録'

    select 'テストビル 101 — テスト太郎', from: '元の契約'
    select '未着手', from: '状態'
    fill_in '更新日', with: '2025-04-01'
    fill_in '現在賃料', with: '100000'
    fill_in '提案賃料', with: '105000'
    fill_in '更新料', with: '100000'
    click_button '登録する'

    expect(page).to have_content '契約更新を登録しました'
    expect(page).to have_content '¥100,000'
  end

  it '契約更新一覧から詳細画面に遷移できる' do
    create(:contract_renewal, contract: contract, status: :pending, current_rent: 100_000)
    visit contract_renewals_path

    click_link '未着手'

    expect(page).to have_content '契約更新詳細'
  end

  it '契約詳細画面から契約更新を作成できる' do
    visit contract_path(contract)

    expect(page).to have_content '更新履歴'
    click_link '契約更新を作成'

    expect(page).to have_content '契約更新登録'
  end
end
