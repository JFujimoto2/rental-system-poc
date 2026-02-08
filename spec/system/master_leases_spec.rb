require 'rails_helper'

RSpec.describe 'マスターリース契約管理', type: :system do
  let!(:owner) { create(:owner, name: 'テストオーナー') }
  let!(:building) { create(:building, owner: owner, name: 'テストビル') }

  it '契約を新規作成して詳細画面に遷移する' do
    visit master_leases_path
    click_link '新規契約登録'

    select 'テストオーナー', from: 'オーナー'
    select 'テストビル', from: '建物'
    select 'サブリース', from: '契約形態'
    fill_in '契約開始日', with: '2024-04-01'
    fill_in '契約終了日', with: '2026-03-31'
    fill_in '保証賃料', with: '500000'
    fill_in '賃料改定周期', with: '24'
    select '契約中', from: '状態'
    click_button '登録する'

    expect(page).to have_content 'マスターリース契約を登録しました'
    expect(page).to have_content 'テストビル'
    expect(page).to have_content 'サブリース'
  end

  it '契約一覧から詳細画面に遷移できる' do
    create(:master_lease, owner: owner, building: building)
    visit master_leases_path

    click_link '詳細'

    expect(page).to have_content 'テストビル'
    expect(page).to have_content 'マスターリース契約'
  end

  it '契約を編集できる' do
    ml = create(:master_lease, owner: owner, building: building, guaranteed_rent: 500_000)
    visit master_lease_path(ml)

    click_link '編集'
    fill_in '保証賃料', with: '480000'
    click_button '更新する'

    expect(page).to have_content 'マスターリース契約を更新しました'
    expect(page).to have_content '480,000'
  end

  it '詳細画面に免責期間が表示される' do
    ml = create(:master_lease, owner: owner, building: building)
    create(:exemption_period, master_lease: ml, start_date: '2024-04-01', end_date: '2024-05-31', reason: '新築')

    visit master_lease_path(ml)

    expect(page).to have_content '免責期間'
    expect(page).to have_content '新築'
  end

  it '詳細画面に賃料改定履歴が表示される' do
    ml = create(:master_lease, owner: owner, building: building)
    create(:rent_revision, master_lease: ml, revision_date: '2026-04-01', old_rent: 500_000, new_rent: 480_000, notes: '市場賃料下落')

    visit master_lease_path(ml)

    expect(page).to have_content '賃料改定履歴'
    expect(page).to have_content '市場賃料下落'
  end
end
