require 'rails_helper'

RSpec.describe '帳票・レポート', type: :system do
  let!(:owner) { create(:owner, name: 'テストオーナー') }
  let!(:building) { create(:building, owner: owner, name: 'テストビル') }
  let!(:room) { create(:room, building: building, room_number: '101', status: :occupied) }
  let!(:room2) { create(:room, building: building, room_number: '102', status: :vacant) }
  let!(:tenant) { create(:tenant, name: 'テスト太郎') }
  let!(:master_lease) { create(:master_lease, owner: owner, building: building) }
  let!(:contract) { create(:contract, room: room, tenant: tenant, rent: 100_000, master_lease: master_lease) }

  describe '物件別収支サマリ' do
    before do
      create(:tenant_payment, contract: contract, due_date: Date.current.beginning_of_month,
             amount: 100_000, paid_amount: 100_000, status: :paid)
      create(:owner_payment, master_lease: master_lease, target_month: Date.current.beginning_of_month,
             guaranteed_amount: 80_000, deduction: 0, net_amount: 80_000, status: :paid)
    end

    it '物件別の収支が表示される' do
      visit property_pl_reports_path

      expect(page).to have_content '物件別収支サマリ'
      expect(page).to have_content 'テストビル'
      expect(page).to have_content 'テストオーナー'
    end

    it 'CSVダウンロードリンクが表示される' do
      visit property_pl_reports_path

      expect(page).to have_link 'CSV ダウンロード'
    end
  end

  describe '債権滞留表' do
    before do
      create(:tenant_payment, contract: contract, due_date: 20.days.ago.to_date,
             amount: 100_000, status: :overdue)
      create(:tenant_payment, contract: contract, due_date: 80.days.ago.to_date,
             amount: 80_000, status: :overdue)
    end

    it 'エイジング区分ごとに滞納が表示される' do
      visit aging_reports_path

      expect(page).to have_content '債権滞留表'
      expect(page).to have_content '〜30日'
      expect(page).to have_content '61〜90日'
      expect(page).to have_content 'テスト太郎'
    end

    it 'CSVダウンロードリンクが表示される' do
      visit aging_reports_path

      expect(page).to have_link 'CSV ダウンロード'
    end
  end

  describe '入金実績レポート' do
    before do
      create(:tenant_payment, contract: contract, due_date: Date.current.beginning_of_month,
             amount: 100_000, paid_amount: 100_000, status: :paid, payment_method: :transfer)
    end

    it '月別の入金実績が表示される' do
      visit payment_summary_reports_path

      expect(page).to have_content '入金実績レポート'
      expect(page).to have_content '入金率'
    end

    it 'CSVダウンロードリンクが表示される' do
      visit payment_summary_reports_path

      expect(page).to have_link 'CSV ダウンロード'
    end
  end
end
