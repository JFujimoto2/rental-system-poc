class Approval < ApplicationRecord
  belongs_to :approvable, polymorphic: true
  belongs_to :requester, class_name: "User"
  belongs_to :approver, class_name: "User", optional: true

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :status, presence: true
  validates :requested_at, presence: true

  def approve!(approver:, comment: nil)
    update!(
      status: :approved,
      approver: approver,
      decided_at: Time.current,
      comment: comment
    )
    activate_approvable!
  end

  def reject!(approver:, comment: nil)
    update!(
      status: :rejected,
      approver: approver,
      decided_at: Time.current,
      comment: comment
    )
  end

  def status_label
    I18n.t("activerecord.enums.approval.status.#{status}")
  end

  private

  def activate_approvable!
    case approvable
    when Contract
      approvable.update!(status: :active)
    when Construction
      approvable.update!(status: :ordered)
    end
  end
end
