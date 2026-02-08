class Owner < ApplicationRecord
  has_many :buildings

  validates :name, presence: true
end
