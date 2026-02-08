class Contract < ApplicationRecord
  belongs_to :room
  belongs_to :tenant
  belongs_to :master_lease, optional: true
  has_many :tenant_payments, dependent: :destroy
  has_many :settlements, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy

  enum :lease_type, { ordinary: 0, fixed_term: 1 }
  enum :status, { applying: 0, active: 1, scheduled_termination: 2, terminated: 3 }

  def self.search(params)
    scope = all
    scope = scope.joins(room: :building).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.joins(:tenant).where("tenants.name ILIKE ?", "%#{params[:tenant_name]}%") if params[:tenant_name].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(lease_type: params[:lease_type]) if params[:lease_type].present?
    scope
  end

  validates :lease_type, presence: true
  validates :start_date, presence: true
  validates :status, presence: true

  def lease_type_label
    return unless lease_type
    I18n.t("activerecord.enums.contract.lease_type.#{lease_type}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.contract.status.#{status}")
  end
end
