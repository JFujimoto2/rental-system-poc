require 'rails_helper'

RSpec.describe 'Tenants' do
  let!(:tenant) { create(:tenant) }

  describe 'GET /tenants' do
    it '一覧を表示できる' do
      get tenants_path
      expect(response).to have_http_status(:success)
    end

    it '名前で検索できる' do
      get tenants_path, params: { q: { name: "山田" } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /tenants.csv' do
    it 'CSVをダウンロードできる' do
      get tenants_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
      expect(response.body).to include("入居者名")
    end
  end

  describe 'GET /tenants/:id' do
    it '詳細を表示できる' do
      get tenant_path(tenant)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /tenants/new' do
    it '新規作成フォームを表示できる' do
      get new_tenant_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /tenants' do
    it '入居者を作成できる' do
      expect {
        post tenants_path, params: { tenant: { name: '新規入居者', phone: '080-0000-0000' } }
      }.to change(Tenant, :count).by(1)
      expect(response).to redirect_to(tenant_path(Tenant.last))
    end
  end

  describe 'GET /tenants/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_tenant_path(tenant)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /tenants/:id' do
    it '入居者を更新できる' do
      patch tenant_path(tenant), params: { tenant: { name: '更新後入居者' } }
      expect(response).to redirect_to(tenant_path(tenant))
      expect(tenant.reload.name).to eq '更新後入居者'
    end
  end

  describe 'DELETE /tenants/:id' do
    it '入居者を削除できる' do
      expect {
        delete tenant_path(tenant)
      }.to change(Tenant, :count).by(-1)
      expect(response).to redirect_to(tenants_path)
    end
  end
end
