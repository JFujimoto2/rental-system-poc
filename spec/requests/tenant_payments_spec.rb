require 'rails_helper'

RSpec.describe 'TenantPayments' do
  let!(:building) { create(:building) }
  let!(:room) { create(:room, building: building) }
  let!(:tenant) { create(:tenant) }
  let!(:contract) { create(:contract, room: room, tenant: tenant) }
  let!(:tenant_payment) { create(:tenant_payment, contract: contract) }

  describe 'GET /tenant_payments' do
    it '一覧を表示できる' do
      get tenant_payments_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /tenant_payments/:id' do
    it '詳細を表示できる' do
      get tenant_payment_path(tenant_payment)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /tenant_payments/new' do
    it '新規作成フォームを表示できる' do
      get new_tenant_payment_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /tenant_payments' do
    it '入金予定を作成できる' do
      expect {
        post tenant_payments_path, params: {
          tenant_payment: {
            contract_id: contract.id,
            due_date: '2024-06-27',
            amount: 85_000,
            status: 'unpaid'
          }
        }
      }.to change(TenantPayment, :count).by(1)
      expect(response).to redirect_to(tenant_payment_path(TenantPayment.last))
    end
  end

  describe 'GET /tenant_payments/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_tenant_payment_path(tenant_payment)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /tenant_payments/:id' do
    it '入金消込ができる' do
      patch tenant_payment_path(tenant_payment), params: {
        tenant_payment: { paid_amount: 85_000, paid_date: '2024-05-27', status: 'paid', payment_method: 'transfer' }
      }
      expect(response).to redirect_to(tenant_payment_path(tenant_payment))
      expect(tenant_payment.reload.status).to eq 'paid'
    end
  end

  describe 'DELETE /tenant_payments/:id' do
    it '入金予定を削除できる' do
      expect {
        delete tenant_payment_path(tenant_payment)
      }.to change(TenantPayment, :count).by(-1)
      expect(response).to redirect_to(tenant_payments_path)
    end
  end
end
