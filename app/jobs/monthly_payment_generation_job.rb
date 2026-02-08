class MonthlyPaymentGenerationJob < ApplicationJob
  queue_as :default

  def perform
    next_month = Date.current.next_month.beginning_of_month
    count = 0

    Contract.where(status: :active).find_each do |contract|
      next if contract.tenant_payments.exists?(due_date: next_month..next_month.end_of_month)

      contract.tenant_payments.create!(
        due_date: next_month,
        amount: contract.rent,
        status: :unpaid
      )
      count += 1
    end

    Rails.logger.info "[MonthlyPaymentGenerationJob] #{count}件の入金予定を生成しました"
    count
  end
end
