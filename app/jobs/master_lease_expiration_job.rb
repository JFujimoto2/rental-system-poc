class MasterLeaseExpirationJob < ApplicationJob
  queue_as :default

  def perform
    count = 0
    MasterLease.where(status: :active)
               .where.not(end_date: nil)
               .where("end_date < ?", Date.current)
               .find_each do |ml|
      ml.update!(status: :terminated)
      ml.contracts.where(status: [ :active, :scheduled_termination ]).find_each do |contract|
        contract.update!(status: :terminated)
      end
      count += 1
    end

    Rails.logger.info "[MasterLeaseExpirationJob] #{count}件のマスターリースを解約済に更新しました"
    count
  end
end
