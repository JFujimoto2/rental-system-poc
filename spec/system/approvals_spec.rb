require 'rails_helper'

RSpec.describe '承認ワークフロー', type: :system do
  let!(:operator) { create(:user, :operator) }
  let!(:building) { create(:building, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101') }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }
  let!(:contract) { create(:contract, room: room, tenant: tenant, status: :applying) }

  describe '承認待ち一覧' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '承認待ちの申請が一覧表示される' do
      visit approvals_path

      expect(page).to have_content '承認待ち一覧'
      expect(page).to have_content 'テスト太郎'
      expect(page).to have_content '承認待ち'
    end
  end

  describe '承認操作' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '承認するとステータスが更新される' do
      visit approval_path(approval)

      expect(page).to have_content '承認詳細'
      expect(page).to have_content 'テスト太郎'

      first('.approval-form') do
        click_button '承認する'
      end

      expect(page).to have_content '承認しました'
      expect(page).to have_content '承認済'
    end
  end

  describe '自分の申請一覧' do
    it '自分が申請した承認が表示される' do
      create(:approval, approvable: contract, requester: @current_test_user)

      visit my_requests_approvals_path

      expect(page).to have_content '申請状況一覧'
      expect(page).to have_content 'テスト太郎'
    end
  end

  describe '契約画面からの承認連携' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '契約詳細画面に承認状態が表示される' do
      visit contract_path(contract)

      expect(page).to have_content '承認状態'
    end
  end
end
