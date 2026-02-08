class Contract < ApplicationRecord
  belongs_to :room
  belongs_to :tenant
  belongs_to :master_lease, optional: true

  enum :lease_type, { ordinary: 0, fixed_term: 1 }
  enum :status, { applying: 0, active: 1, scheduled_termination: 2, terminated: 3 }

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
