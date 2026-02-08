class Insurance < ApplicationRecord
  belongs_to :building, optional: true
  belongs_to :room, optional: true

  enum :insurance_type, { fire: 0, earthquake: 1, tenant_liability: 2, facility_liability: 3, other: 4 }
  enum :status, { active: 0, expiring_soon: 1, expired: 2, cancelled: 3 }

  validates :insurance_type, presence: true
  validates :status, presence: true
  validate :building_or_room_present

  def self.search(params)
    scope = all
    scope = scope.joins(:building).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.where(insurance_type: params[:insurance_type]) if params[:insurance_type].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where("provider ILIKE ?", "%#{params[:provider]}%") if params[:provider].present?
    scope
  end

  def insurance_type_label
    return unless insurance_type
    I18n.t("activerecord.enums.insurance.insurance_type.#{insurance_type}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.insurance.status.#{status}")
  end

  private

  def building_or_room_present
    if building_id.blank? && room_id.blank?
      errors.add(:base, "建物または部屋のいずれかを指定してください")
    end
  end
end
