class Settlement < ApplicationRecord
  belongs_to :contract

  enum :settlement_type, { tenant_rent: 0, tenant_deposit: 1 }
  enum :status, { draft: 0, confirmed: 1, paid: 2 }

  validates :settlement_type, presence: true
  validates :termination_date, presence: true
  validates :status, presence: true

  def calculate_prorated_rent
    return unless contract&.rent && termination_date

    days_in_month = Time.days_in_month(termination_date.month, termination_date.year)
    self.daily_rent = contract.rent / days_in_month
    self.days_count = termination_date.day
    self.prorated_rent = daily_rent * days_count
  end

  def calculate_deposit_refund
    self.refund_amount = (deposit_amount || 0) - (restoration_cost || 0) - (other_deductions || 0)
  end

  def settlement_type_label
    return unless settlement_type
    I18n.t("activerecord.enums.settlement.settlement_type.#{settlement_type}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.settlement.status.#{status}")
  end
end
