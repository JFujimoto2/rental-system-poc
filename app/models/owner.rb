class Owner < ApplicationRecord
  has_many :buildings
  has_many :master_leases

  validates :name, presence: true
end
