require 'rails_helper'

RSpec.describe 'テナント入金管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, status: :active) }

  it 'テナント入金を新規作成して詳細画面に遷移する' do
    visit tenant_payments_path
    click_link '新規入金登録'

    select 'テストビル 101（テスト太郎）', from: '転貸借契約'
    fill_in '入金期日', with: '2024-06-27'
    fill_in '請求金額', with: '85000'
    select '未入金', from: '状態'
    click_button '登録する'

    expect(page).to have_content 'テナント入金を登録しました'
    expect(page).to have_content 'テスト太郎'
    expect(page).to have_content '85,000'
  end

  it 'テナント入金一覧から詳細画面に遷移できる' do
    create(:tenant_payment, contract: contract)
    visit tenant_payments_path

    click_link '詳細'

    expect(page).to have_content 'テスト太郎'
    expect(page).to have_content 'テナント入金詳細'
  end

  it 'テナント入金を編集して消込できる' do
    tp = create(:tenant_payment, contract: contract, amount: 85_000)
    visit tenant_payment_path(tp)

    click_link '編集'
    fill_in '入金額', with: '85000'
    fill_in '入金日', with: '2024-06-25'
    select '入金済', from: '状態'
    select '振込', from: '入金方法'
    click_button '更新する'

    expect(page).to have_content 'テナント入金を更新しました'
    expect(page).to have_content '入金済'
    expect(page).to have_content '振込'
  end

  it '契約詳細画面にテナント入金履歴が表示される' do
    create(:tenant_payment, contract: contract)
    visit contract_path(contract)

    expect(page).to have_content 'テナント入金履歴'
    expect(page).to have_content '未入金'
  end
end
