class Tenant < ApplicationRecord
  has_many :contracts

  validates :name, presence: true
end
