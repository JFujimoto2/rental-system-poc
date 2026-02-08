class ApprovalsController < ApplicationController
  before_action :authorize_approval!, only: [ :approve, :reject ]
  before_action :set_approval, only: [ :show, :approve, :reject ]

  def index
    @approvals = Approval.pending
                         .includes(:requester, :approvable)
                         .order(requested_at: :desc)
  end

  def my_requests
    @approvals = current_user.requested_approvals
                             .includes(:approver, :approvable)
                             .order(requested_at: :desc)
  end

  def show
  end

  def approve
    @approval.approve!(approver: current_user, comment: params.dig(:approval, :comment))
    redirect_to approval_path(@approval), notice: "承認しました。"
  end

  def reject
    @approval.reject!(approver: current_user, comment: params.dig(:approval, :comment))
    redirect_to approval_path(@approval), notice: "却下しました。"
  end

  private

  def set_approval
    @approval = Approval.find(params[:id])
  end

  def authorize_approval!
    return if current_user&.can_approve?
    redirect_to root_path, alert: "この操作を行う権限がありません。"
  end
end
