class Building < ApplicationRecord
  belongs_to :owner, optional: true
  has_many :rooms, dependent: :destroy
  has_many :master_leases

  validates :name, presence: true
end
