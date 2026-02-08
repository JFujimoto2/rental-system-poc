class Tenant < ApplicationRecord
  has_many :contracts

  validates :name, presence: true

  def self.search(params)
    scope = all
    scope = scope.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where("name_kana ILIKE ?", "%#{params[:name_kana]}%") if params[:name_kana].present?
    scope = scope.where("phone ILIKE ?", "%#{params[:phone]}%") if params[:phone].present?
    scope
  end
end
