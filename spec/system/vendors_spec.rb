require 'rails_helper'

RSpec.describe '業者管理', type: :system do
  it '業者を新規作成して詳細画面に遷移する' do
    visit vendors_path
    click_link '新規業者登録'

    fill_in '業者名', with: 'テスト工務店'
    fill_in '電話番号', with: '03-1234-5678'
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in '住所', with: '東京都渋谷区1-1-1'
    fill_in '担当者名', with: '山田太郎'
    click_button '登録する'

    expect(page).to have_content '業者を登録しました'
    expect(page).to have_content 'テスト工務店'
  end

  it '業者一覧から詳細画面に遷移できる' do
    create(:vendor, name: '表示テスト業者')
    visit vendors_path

    click_link '表示テスト業者'

    expect(page).to have_content '表示テスト業者'
  end

  it '業者を編集できる' do
    vendor = create(:vendor, name: '編集前業者')
    visit vendor_path(vendor)

    click_link '編集'
    fill_in '業者名', with: '編集後業者'
    click_button '更新する'

    expect(page).to have_content '編集後業者'
    expect(page).to have_content '業者を更新しました'
  end

  it '業者を削除できる' do
    create(:vendor, name: '削除対象業者')
    visit vendors_path

    click_link '削除対象業者'
    accept_confirm { click_button '削除' }

    expect(page).not_to have_content '削除対象業者'
  end
end
