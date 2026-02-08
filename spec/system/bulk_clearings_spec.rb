require 'rails_helper'

RSpec.describe '入金一括消込', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: '山田 太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 100_000) }
  let!(:unpaid) do
    create(:tenant_payment, contract: contract, due_date: '2024-06-01',
           amount: 100_000, status: :unpaid)
  end

  it 'CSVをアップロードして照合結果を確認できる' do
    csv_path = Rails.root.join('tmp/test_clearing.csv')
    File.write(csv_path, "振込日,振込人名,金額\n2024-06-01,山田 太郎,100000\n")

    visit new_bulk_clearing_path

    expect(page).to have_content '入金一括消込'

    attach_file 'CSVファイル', csv_path
    click_button 'アップロードして照合'

    expect(page).to have_content '照合結果'
    expect(page).to have_content '山田 太郎'
    expect(page).to have_content '完全一致'
  ensure
    FileUtils.rm_f(csv_path)
  end

  it '照合結果から一括消込を実行できる' do
    csv_path = Rails.root.join('tmp/test_clearing2.csv')
    File.write(csv_path, "振込日,振込人名,金額\n2024-06-01,山田 太郎,100000\n")

    visit new_bulk_clearing_path
    attach_file 'CSVファイル', csv_path
    click_button 'アップロードして照合'

    click_button '選択した入金を消込'

    expect(page).to have_content '1件の入金を消込しました'
    expect(unpaid.reload.status).to eq 'paid'
  ensure
    FileUtils.rm_f(csv_path)
  end
end
