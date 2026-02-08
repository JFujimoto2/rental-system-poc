class Building < ApplicationRecord
  belongs_to :owner, optional: true
  has_many :rooms, dependent: :destroy

  validates :name, presence: true
end
