class OverdueDetectionJob < ApplicationJob
  queue_as :default

  def perform
    count = TenantPayment.where(status: :unpaid)
                         .where("due_date < ?", Date.current)
                         .update_all(status: TenantPayment.statuses[:overdue])

    Rails.logger.info "[OverdueDetectionJob] #{count}件の未入金を滞納に更新しました"
    count
  end
end
