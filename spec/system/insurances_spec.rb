require 'rails_helper'

RSpec.describe '保険管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }

  it '建物単位の保険を新規作成して詳細画面に遷移する' do
    visit insurances_path
    click_link '新規保険登録'

    select 'テストビル', from: '建物'
    select '火災保険', from: '保険種別'
    select '有効', from: '状態'
    fill_in '証券番号', with: 'POL-001'
    fill_in '保険会社名', with: 'テスト損保'
    fill_in '開始日', with: '2025-01-01'
    fill_in '終了日', with: '2026-01-01'
    click_button '登録する'

    expect(page).to have_content '保険を登録しました'
    expect(page).to have_content 'POL-001'
  end

  it '保険一覧から詳細画面に遷移できる' do
    create(:insurance, building: building, insurance_type: :fire, status: :active, policy_number: 'POL-002', provider: 'テスト損保')
    visit insurances_path

    click_link '有効'

    expect(page).to have_content 'POL-002'
  end

  it '保険を編集できる' do
    insurance = create(:insurance, building: building, insurance_type: :fire, policy_number: 'POL-003', provider: '編集前損保')
    visit insurance_path(insurance)

    click_link '編集'
    fill_in '保険会社名', with: '編集後損保'
    click_button '更新する'

    expect(page).to have_content '編集後損保'
    expect(page).to have_content '保険を更新しました'
  end
end
