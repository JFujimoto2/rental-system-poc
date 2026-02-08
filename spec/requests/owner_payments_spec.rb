require 'rails_helper'

RSpec.describe 'OwnerPayments' do
  let!(:owner) { create(:owner) }
  let!(:building) { create(:building, owner: owner) }
  let!(:master_lease) { create(:master_lease, owner: owner, building: building) }
  let!(:owner_payment) { create(:owner_payment, master_lease: master_lease) }

  describe 'GET /owner_payments' do
    it '一覧を表示できる' do
      get owner_payments_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /owner_payments/:id' do
    it '詳細を表示できる' do
      get owner_payment_path(owner_payment)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /owner_payments/new' do
    it '新規作成フォームを表示できる' do
      get new_owner_payment_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /owner_payments' do
    it 'オーナー支払を作成できる' do
      expect {
        post owner_payments_path, params: {
          owner_payment: {
            master_lease_id: master_lease.id,
            target_month: '2024-06-01',
            guaranteed_amount: 500_000,
            deduction: 0,
            net_amount: 500_000,
            status: 'unpaid'
          }
        }
      }.to change(OwnerPayment, :count).by(1)
      expect(response).to redirect_to(owner_payment_path(OwnerPayment.last))
    end
  end

  describe 'GET /owner_payments/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_owner_payment_path(owner_payment)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /owner_payments/:id' do
    it 'オーナー支払を処理できる' do
      patch owner_payment_path(owner_payment), params: {
        owner_payment: { paid_date: '2024-05-31', status: 'paid' }
      }
      expect(response).to redirect_to(owner_payment_path(owner_payment))
      expect(owner_payment.reload.status).to eq 'paid'
    end
  end

  describe 'DELETE /owner_payments/:id' do
    it 'オーナー支払を削除できる' do
      expect {
        delete owner_payment_path(owner_payment)
      }.to change(OwnerPayment, :count).by(-1)
      expect(response).to redirect_to(owner_payments_path)
    end
  end
end
