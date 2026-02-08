require 'rails_helper'

RSpec.describe '滞納管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: '滞納太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant) }
  let!(:overdue) do
    create(:tenant_payment, contract: contract, due_date: 45.days.ago.to_date,
           amount: 100_000, status: :overdue)
  end

  it '滞納一覧に滞納データが表示される' do
    visit delinquencies_path

    expect(page).to have_content '滞納一覧'
    expect(page).to have_content '滞納太郎'
    expect(page).to have_content 'テストビル'
    expect(page).to have_content '101'
  end

  it '入居者名で検索できる' do
    create(:tenant_payment, contract: create(:contract, tenant: create(:tenant, name: '他の人')),
           due_date: 10.days.ago.to_date, amount: 50_000, status: :overdue)

    visit delinquencies_path
    fill_in 'q[tenant_name]', with: '滞納太郎'
    click_button '検索'

    expect(page).to have_content '滞納太郎'
    expect(page).not_to have_content '他の人'
  end

  it 'CSVダウンロードリンクが表示される' do
    visit delinquencies_path

    expect(page).to have_link 'CSV ダウンロード'
  end
end
