require 'rails_helper'

RSpec.describe 'Insurances' do
  let!(:insurance) { create(:insurance) }

  describe 'GET /insurances' do
    it '一覧を表示できる' do
      get insurances_path
      expect(response).to have_http_status(:success)
    end

    it '保険種別で検索できる' do
      get insurances_path, params: { q: { insurance_type: "fire" } }
      expect(response).to have_http_status(:success)
    end

    it '保険会社名で検索できる' do
      create(:insurance, provider: "損保ジャパン")
      get insurances_path, params: { q: { provider: "損保" } }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("損保ジャパン")
    end
  end

  describe 'GET /insurances.csv' do
    it 'CSVをダウンロードできる' do
      get insurances_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it 'CSVにBOMが付与される' do
      get insurances_path(format: :csv)
      expect(response.body.bytes[0..2]).to eq [ 0xEF, 0xBB, 0xBF ]
    end
  end

  describe 'GET /insurances/:id' do
    it '詳細を表示できる' do
      get insurance_path(insurance)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /insurances/new' do
    it '新規作成フォームを表示できる' do
      get new_insurance_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /insurances' do
    let(:building) { create(:building) }

    it '保険を作成できる' do
      expect {
        post insurances_path, params: { insurance: {
          building_id: building.id, insurance_type: "fire", status: "active",
          provider: "テスト保険会社", policy_number: "POL-999"
        } }
      }.to change(Insurance, :count).by(1)
      expect(response).to redirect_to(insurance_path(Insurance.last))
    end
  end

  describe 'GET /insurances/:id/edit' do
    it '編集フォームを表示できる' do
      get edit_insurance_path(insurance)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /insurances/:id' do
    it '保険を更新できる' do
      patch insurance_path(insurance), params: { insurance: { provider: "更新保険会社" } }
      expect(response).to redirect_to(insurance_path(insurance))
      expect(insurance.reload.provider).to eq "更新保険会社"
    end
  end

  describe 'DELETE /insurances/:id' do
    it '保険を削除できる' do
      expect {
        delete insurance_path(insurance)
      }.to change(Insurance, :count).by(-1)
      expect(response).to redirect_to(insurances_path)
    end
  end
end
