require 'rails_helper'

RSpec.describe '入居者管理', type: :system do
  it '入居者を新規作成して詳細画面に遷移する' do
    visit tenants_path
    click_link '新規入居者登録'

    fill_in '入居者名', with: 'テスト太郎'
    fill_in '入居者名カナ', with: 'テストタロウ'
    fill_in '電話番号', with: '090-0000-0000'
    fill_in 'メールアドレス', with: 'test@example.com'
    click_button '登録する'

    expect(page).to have_content 'テスト太郎'
    expect(page).to have_content '入居者を登録しました'
  end

  it '入居者一覧から詳細画面に遷移できる' do
    create(:tenant, name: '表示テスト太郎')
    visit tenants_path

    click_link '表示テスト太郎'

    expect(page).to have_content '表示テスト太郎'
  end

  it '入居者を編集できる' do
    tenant = create(:tenant, name: '編集前太郎')
    visit tenant_path(tenant)

    click_link '編集'
    fill_in '入居者名', with: '編集後太郎'
    click_button '更新する'

    expect(page).to have_content '編集後太郎'
    expect(page).to have_content '入居者を更新しました'
  end

  it '詳細画面に契約一覧が表示される' do
    tenant = create(:tenant, name: '契約持ち太郎')
    building = create(:building, name: '契約テストビル')
    room = create(:room, building: building, room_number: '101')
    create(:contract, tenant: tenant, room: room, status: :active)

    visit tenant_path(tenant)

    expect(page).to have_content '契約一覧'
    expect(page).to have_content '契約テストビル'
    expect(page).to have_content '101'
  end
end
