class RoomStatusSyncJob < ApplicationJob
  queue_as :default

  def perform
    noticed = sync_notice_rooms
    vacated = sync_vacant_rooms

    Rails.logger.info "[RoomStatusSyncJob] 退去予定: #{noticed}件, 空室化: #{vacated}件"
    { noticed: noticed, vacated: vacated }
  end

  private

  def sync_notice_rooms
    count = 0
    Contract.where(status: :scheduled_termination).find_each do |contract|
      if contract.room.occupied?
        contract.room.update!(status: :notice)
        count += 1
      end
    end
    count
  end

  def sync_vacant_rooms
    count = 0
    Room.where(status: [ :occupied, :notice ]).find_each do |room|
      active_contracts = room.contracts.where(status: [ :active, :scheduled_termination ]).count
      if active_contracts.zero?
        room.update!(status: :vacant)
        count += 1
      end
    end
    count
  end
end
