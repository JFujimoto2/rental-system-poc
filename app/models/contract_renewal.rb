class ContractRenewal < ApplicationRecord
  belongs_to :contract
  belongs_to :new_contract, class_name: "Contract", optional: true

  enum :status, { pending: 0, notified: 1, negotiating: 2, agreed: 3, renewed: 4, declined: 5, cancelled: 6 }

  validates :status, presence: true

  def self.search(params)
    scope = all
    scope = scope.joins(contract: { room: :building }).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.joins(contract: :tenant).where("tenants.name ILIKE ?", "%#{params[:tenant_name]}%") if params[:tenant_name].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.contract_renewal.status.#{status}")
  end
end
