class MasterLease < ApplicationRecord
  belongs_to :owner
  belongs_to :building
  has_many :exemption_periods, dependent: :destroy
  has_many :rent_revisions, dependent: :destroy

  enum :contract_type, { sublease: 0, management: 1, own: 2 }
  enum :status, { active: 0, scheduled_termination: 1, terminated: 2 }

  validates :contract_type, presence: true
  validates :start_date, presence: true
  validates :status, presence: true

  def contract_type_label
    return unless contract_type
    I18n.t("activerecord.enums.master_lease.contract_type.#{contract_type}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.master_lease.status.#{status}")
  end
end
