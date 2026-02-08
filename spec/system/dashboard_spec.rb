require 'rails_helper'

RSpec.describe 'ダッシュボード', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room_occupied) { create(:room, building: building, room_number: '101', status: :occupied) }
  let!(:room_vacant) { create(:room, building: building, room_number: '102', status: :vacant) }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }
  let!(:contract) { create(:contract, room: room_occupied, tenant: tenant, status: :active, end_date: 2.months.from_now.to_date) }

  it 'ダッシュボードにKPIが表示される' do
    visit root_path

    expect(page).to have_content 'ダッシュボード'
    expect(page).to have_content '入居状況'
    expect(page).to have_content '入居率'
    expect(page).to have_content '50.0%'
  end

  it '滞納状況が表示される' do
    create(:tenant_payment, contract: contract, due_date: 1.month.ago.to_date,
           amount: 100_000, status: :overdue)

    visit root_path

    expect(page).to have_content '滞納状況'
    expect(page).to have_content '1'
  end

  it '契約更新予定が表示される' do
    visit root_path

    expect(page).to have_content '契約更新予定'
    expect(page).to have_content 'テスト太郎'
    expect(page).to have_content 'テストビル'
  end

  it '解約予定が表示される' do
    create(:contract, room: room_vacant, tenant: create(:tenant, name: '退去者'),
           status: :scheduled_termination, end_date: 1.month.from_now.to_date)

    visit root_path

    expect(page).to have_content '解約予定'
    expect(page).to have_content '退去者'
  end
end
