class Room < ApplicationRecord
  belongs_to :building
  has_many :contracts

  enum :status, { vacant: 0, occupied: 1, notice: 2 }

  validates :room_number, presence: true

  def self.search(params)
    scope = all
    scope = scope.where(building_id: params[:building_id]) if params[:building_id].present?
    scope = scope.where("room_number ILIKE ?", "%#{params[:room_number]}%") if params[:room_number].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where("room_type ILIKE ?", "%#{params[:room_type]}%") if params[:room_type].present?
    scope
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.room.status.#{status}")
  end
end
