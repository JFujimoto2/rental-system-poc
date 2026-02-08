require 'rails_helper'

RSpec.describe '問い合わせ管理', type: :system do
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }

  it '問い合わせを新規作成して詳細画面に遷移する' do
    visit inquiries_path
    click_link '新規問い合わせ登録'

    fill_in '件名', with: 'エアコン故障'
    select '修繕依頼', from: 'カテゴリ'
    select '高', from: '優先度'
    select '受付', from: '状態'
    fill_in '受付日', with: '2025-01-15'
    click_button '登録する'

    expect(page).to have_content '問い合わせを登録しました'
    expect(page).to have_content 'エアコン故障'
  end

  it '問い合わせ一覧から詳細画面に遷移できる' do
    create(:inquiry, title: '表示テスト問い合わせ', room: room, tenant: tenant, category: :repair, priority: :normal, status: :received)
    visit inquiries_path

    click_link '表示テスト問い合わせ'

    expect(page).to have_content '表示テスト問い合わせ'
  end

  it '問い合わせを編集できる' do
    inquiry = create(:inquiry, title: '編集前問い合わせ', category: :repair, priority: :normal, status: :received)
    visit inquiry_path(inquiry)

    click_link '編集'
    fill_in '件名', with: '編集後問い合わせ'
    click_button '更新する'

    expect(page).to have_content '編集後問い合わせ'
    expect(page).to have_content '問い合わせを更新しました'
  end
end
