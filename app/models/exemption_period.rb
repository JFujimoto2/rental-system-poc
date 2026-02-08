class ExemptionPeriod < ApplicationRecord
  belongs_to :master_lease
  belongs_to :room, optional: true

  validates :start_date, presence: true
  validates :end_date, presence: true
end
