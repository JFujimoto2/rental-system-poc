class MonthlyOwnerPaymentGenerationJob < ApplicationJob
  queue_as :default

  def perform
    next_month = Date.current.next_month.beginning_of_month
    count = 0

    MasterLease.where(status: :active).find_each do |ml|
      next if ml.owner_payments.exists?(target_month: next_month..next_month.end_of_month)

      ml.owner_payments.create!(
        target_month: next_month,
        guaranteed_amount: ml.guaranteed_rent,
        deduction: 0,
        net_amount: ml.guaranteed_rent,
        status: :unpaid
      )
      count += 1
    end

    Rails.logger.info "[MonthlyOwnerPaymentGenerationJob] #{count}件のオーナー支払を生成しました"
    count
  end
end
