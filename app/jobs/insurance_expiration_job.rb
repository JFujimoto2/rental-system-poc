class InsuranceExpirationJob < ApplicationJob
  queue_as :default

  def perform
    count = Insurance.where(status: :active)
                     .where("end_date <= ?", 30.days.from_now.to_date)
                     .update_all(status: Insurance.statuses[:expiring_soon])

    Rails.logger.info "[InsuranceExpirationJob] #{count}件の保険を期限間近に更新しました"
    count
  end
end
