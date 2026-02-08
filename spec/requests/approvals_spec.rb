require 'rails_helper'

RSpec.describe 'Approvals' do
  let!(:operator) { create(:user, :operator) }
  let!(:manager) { create(:user, :manager) }
  let!(:contract) { create(:contract, status: :applying) }

  describe 'GET /approvals（承認待ち一覧）' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '承認待ち一覧を表示できる' do
      get approvals_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('承認待ち一覧')
    end

    it '承認待ちの件が表示される' do
      get approvals_path
      expect(response.body).to include(contract.tenant.name)
    end
  end

  describe 'GET /approvals/my_requests（自分の申請一覧）' do
    it '自分の申請一覧を表示できる' do
      create(:approval, approvable: contract, requester: @current_test_user)
      get my_requests_approvals_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('申請状況一覧')
    end
  end

  describe 'GET /approvals/:id（承認詳細）' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '承認詳細を表示できる' do
      get approval_path(approval)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('承認詳細')
    end
  end

  describe 'PATCH /approvals/:id/approve（承認）' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '承認するとステータスがapprovedになる' do
      patch approve_approval_path(approval), params: { approval: { comment: '承認します' } }
      expect(response).to redirect_to(approval_path(approval))
      expect(approval.reload.status).to eq 'approved'
      expect(approval.approver).to eq @current_test_user
    end

    it '承認すると契約がactiveになる' do
      patch approve_approval_path(approval)
      expect(contract.reload.status).to eq 'active'
    end
  end

  describe 'PATCH /approvals/:id/reject（却下）' do
    let!(:approval) { create(:approval, approvable: contract, requester: operator) }

    it '却下するとステータスがrejectedになる' do
      patch reject_approval_path(approval), params: { approval: { comment: '内容を修正してください' } }
      expect(response).to redirect_to(approval_path(approval))
      expect(approval.reload.status).to eq 'rejected'
      expect(approval.comment).to eq '内容を修正してください'
    end
  end

  describe '契約作成時の自動承認申請' do
    before do
      # operatorでログインし直す
      login_as(operator)
    end

    it 'operatorが契約を作成すると承認申請が自動生成される' do
      room = create(:room)
      tenant = create(:tenant)
      expect {
        post contracts_path, params: {
          contract: {
            room_id: room.id,
            tenant_id: tenant.id,
            lease_type: :ordinary,
            start_date: '2024-04-01',
            end_date: '2026-03-31',
            rent: 100_000,
            status: :applying
          }
        }
      }.to change(Approval, :count).by(1)

      approval = Approval.last
      expect(approval.requester).to eq operator
      expect(approval.status).to eq 'pending'
      expect(approval.approvable).to be_a(Contract)
    end

    it 'adminが契約を作成すると承認申請は生成されない' do
      login_as(@current_test_user) # admin
      room = create(:room)
      tenant = create(:tenant)
      expect {
        post contracts_path, params: {
          contract: {
            room_id: room.id,
            tenant_id: tenant.id,
            lease_type: :ordinary,
            start_date: '2024-04-01',
            end_date: '2026-03-31',
            rent: 100_000,
            status: :applying
          }
        }
      }.not_to change(Approval, :count)
    end
  end
end
