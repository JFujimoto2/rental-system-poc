class OwnerPayment < ApplicationRecord
  belongs_to :master_lease

  enum :status, { unpaid: 0, paid: 1 }

  def self.search(params)
    scope = all
    scope = scope.joins(master_lease: :owner).where("owners.name ILIKE ?", "%#{params[:owner_name]}%") if params[:owner_name].present?
    scope = scope.joins(master_lease: :building).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where("target_month >= ?", params[:target_month_from]) if params[:target_month_from].present?
    scope = scope.where("target_month <= ?", params[:target_month_to]) if params[:target_month_to].present?
    scope
  end

  validates :target_month, presence: true
  validates :guaranteed_amount, presence: true
  validates :net_amount, presence: true
  validates :status, presence: true

  def status_label
    return unless status
    I18n.t("activerecord.enums.owner_payment.status.#{status}")
  end
end
