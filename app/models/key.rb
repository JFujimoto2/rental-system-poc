class Key < ApplicationRecord
  belongs_to :room
  has_many :key_histories, dependent: :destroy

  enum :key_type, { main: 0, duplicate: 1, spare: 2, mailbox: 3, auto_lock: 4 }
  enum :status, { in_stock: 0, issued: 1, lost: 2, disposed: 3 }

  validates :key_type, presence: true
  validates :status, presence: true

  def self.search(params)
    scope = all
    scope = scope.joins(room: :building).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.joins(:room).where("rooms.room_number ILIKE ?", "%#{params[:room_number]}%") if params[:room_number].present?
    scope = scope.where(key_type: params[:key_type]) if params[:key_type].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope
  end

  def key_type_label
    return unless key_type
    I18n.t("activerecord.enums.key.key_type.#{key_type}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.key.status.#{status}")
  end
end
