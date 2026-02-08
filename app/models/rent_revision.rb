class RentRevision < ApplicationRecord
  belongs_to :master_lease

  validates :revision_date, presence: true
  validates :old_rent, presence: true
  validates :new_rent, presence: true
end
