class TenantPayment < ApplicationRecord
  belongs_to :contract

  enum :status, { unpaid: 0, paid: 1, partial: 2, overdue: 3 }
  enum :payment_method, { transfer: 0, direct_debit: 1, cash: 2 }

  validates :due_date, presence: true
  validates :amount, presence: true
  validates :status, presence: true

  def status_label
    return unless status
    I18n.t("activerecord.enums.tenant_payment.status.#{status}")
  end

  def payment_method_label
    return unless payment_method
    I18n.t("activerecord.enums.tenant_payment.payment_method.#{payment_method}")
  end
end
