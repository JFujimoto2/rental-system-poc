class Vendor < ApplicationRecord
  has_many :constructions

  validates :name, presence: true

  def self.search(params)
    scope = all
    scope = scope.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where("phone ILIKE ?", "%#{params[:phone]}%") if params[:phone].present?
    scope
  end
end
