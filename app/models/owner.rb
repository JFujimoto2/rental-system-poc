class Owner < ApplicationRecord
  has_many :buildings
  has_many :master_leases

  validates :name, presence: true

  def self.search(params)
    scope = all
    scope = scope.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where("phone ILIKE ?", "%#{params[:phone]}%") if params[:phone].present?
    scope = scope.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
    scope
  end
end
