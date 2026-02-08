require 'rails_helper'

RSpec.describe Approval, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:approvable) }
    it { is_expected.to belong_to(:requester).class_name('User') }
    it { is_expected.to belong_to(:approver).class_name('User').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:requested_at) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2).backed_by_column_of_type(:integer) }
  end

  describe '#approve!' do
    let(:approver) { create(:user, :manager) }
    let(:approval) { create(:approval) }

    it '承認ステータスに更新される' do
      approval.approve!(approver: approver, comment: '承認します')

      expect(approval.status).to eq 'approved'
      expect(approval.approver).to eq approver
      expect(approval.decided_at).to be_present
      expect(approval.comment).to eq '承認します'
    end

    it '承認対象のContractがactiveになる' do
      contract = approval.approvable
      contract.update!(status: :applying)

      approval.approve!(approver: approver)

      expect(contract.reload.status).to eq 'active'
    end
  end

  describe '#reject!' do
    let(:approver) { create(:user, :admin) }
    let(:approval) { create(:approval) }

    it '却下ステータスに更新される' do
      approval.reject!(approver: approver, comment: '内容を確認してください')

      expect(approval.status).to eq 'rejected'
      expect(approval.approver).to eq approver
      expect(approval.decided_at).to be_present
      expect(approval.comment).to eq '内容を確認してください'
    end
  end

  describe 'scopes' do
    let!(:pending_approval) { create(:approval, status: :pending) }
    let!(:approved_approval) { create(:approval, status: :approved, approver: create(:user, :manager), decided_at: Time.current) }

    it 'pendingスコープで承認待ちのみ取得できる' do
      expect(Approval.pending).to include(pending_approval)
      expect(Approval.pending).not_to include(approved_approval)
    end
  end

  describe '#status_label' do
    it '日本語ラベルを返す' do
      approval = build(:approval, status: :pending)
      expect(approval.status_label).to eq '承認待ち'
    end
  end
end
