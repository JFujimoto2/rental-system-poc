require 'rails_helper'

RSpec.describe '解約精算', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 150_000, deposit: 300_000, status: :active) }

  it '賃料精算を作成して日割り計算結果を確認できる' do
    visit settlements_path
    click_link '新規精算作成'

    select 'テストビル 101 — テスト太郎', from: '転貸借契約'
    select '賃料精算', from: '精算種別'
    fill_in '解約日', with: '2024-06-15'
    select '下書き', from: '状態'
    click_button '登録する'

    expect(page).to have_content '精算を作成しました'
    expect(page).to have_content '賃料精算'
    expect(page).to have_content '15日'
  end

  it '敷金精算を作成して返還額を確認できる' do
    visit new_settlement_path(contract_id: contract.id)

    select '敷金精算', from: '精算種別'
    fill_in '解約日', with: '2024-06-30'
    fill_in '預かり敷金', with: '300000'
    fill_in '原状回復費用', with: '80000'
    fill_in 'その他控除', with: '20000'
    select '下書き', from: '状態'
    click_button '登録する'

    expect(page).to have_content '精算を作成しました'
    expect(page).to have_content '敷金精算'
    expect(page).to have_content '¥200,000'
  end

  it '精算一覧から詳細画面に遷移できる' do
    create(:settlement, contract: contract, settlement_type: :tenant_rent,
           termination_date: '2024-06-15', daily_rent: 5_000, days_count: 15, prorated_rent: 75_000)

    visit settlements_path
    click_link '詳細'

    expect(page).to have_content '精算詳細'
    expect(page).to have_content 'テスト太郎'
  end

  it '契約詳細画面から精算を作成できる' do
    visit contract_path(contract)

    expect(page).to have_content '精算履歴'
    click_link '精算作成'

    expect(page).to have_content '精算作成'
  end
end
