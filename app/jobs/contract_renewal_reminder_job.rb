class ContractRenewalReminderJob < ApplicationJob
  queue_as :default

  def perform
    count = 0
    Contract.where(status: :active)
            .where("end_date <= ?", 3.months.from_now.to_date)
            .where.not(id: ContractRenewal.select(:contract_id))
            .find_each do |contract|
      ContractRenewal.create!(
        contract: contract,
        status: :pending,
        current_rent: contract.rent
      )
      count += 1
    end

    Rails.logger.info "[ContractRenewalReminderJob] #{count}件の契約更新リマインダーを作成しました"
    count
  end
end
