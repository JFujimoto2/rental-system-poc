class Room < ApplicationRecord
  belongs_to :building
  has_many :contracts

  enum :status, { vacant: 0, occupied: 1, notice: 2 }

  validates :room_number, presence: true

  def status_label
    return unless status
    I18n.t("activerecord.enums.room.status.#{status}")
  end
end
