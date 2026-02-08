class ContractExpirationJob < ApplicationJob
  queue_as :default

  def perform
    count = 0
    Contract.where(status: :scheduled_termination)
            .where("end_date < ?", Date.current)
            .find_each do |contract|
      contract.update!(status: :terminated)
      count += 1
    end

    Rails.logger.info "[ContractExpirationJob] #{count}件の契約を解約済に更新しました"
    count
  end
end
