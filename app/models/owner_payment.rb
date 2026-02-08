class OwnerPayment < ApplicationRecord
  belongs_to :master_lease

  enum :status, { unpaid: 0, paid: 1 }

  validates :target_month, presence: true
  validates :guaranteed_amount, presence: true
  validates :net_amount, presence: true
  validates :status, presence: true

  def status_label
    return unless status
    I18n.t("activerecord.enums.owner_payment.status.#{status}")
  end
end
