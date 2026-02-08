class Construction < ApplicationRecord
  belongs_to :room
  belongs_to :vendor, optional: true
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many :inquiries

  enum :construction_type, { restoration: 0, renovation: 1, repair: 2, equipment: 3, other: 4 }
  enum :status, { draft: 0, ordered: 1, in_progress: 2, completed: 3, invoiced: 4, cancelled: 5 }
  enum :cost_bearer, { company: 0, owner: 1, tenant: 2 }

  validates :title, presence: true
  validates :construction_type, presence: true
  validates :status, presence: true

  def self.search(params)
    scope = all
    scope = scope.joins(room: :building).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.joins(:vendor).where("vendors.name ILIKE ?", "%#{params[:vendor_name]}%") if params[:vendor_name].present?
    scope = scope.where(construction_type: params[:construction_type]) if params[:construction_type].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(cost_bearer: params[:cost_bearer]) if params[:cost_bearer].present?
    scope
  end

  def construction_type_label
    return unless construction_type
    I18n.t("activerecord.enums.construction.construction_type.#{construction_type}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.construction.status.#{status}")
  end

  def cost_bearer_label
    return unless cost_bearer
    I18n.t("activerecord.enums.construction.cost_bearer.#{cost_bearer}")
  end
end
