class Building < ApplicationRecord
  belongs_to :owner, optional: true
  has_many :rooms, dependent: :destroy
  has_many :master_leases

  validates :name, presence: true

  def self.search(params)
    scope = all
    scope = scope.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where("address ILIKE ?", "%#{params[:address]}%") if params[:address].present?
    scope = scope.where(owner_id: params[:owner_id]) if params[:owner_id].present?
    scope = scope.where("building_type ILIKE ?", "%#{params[:building_type]}%") if params[:building_type].present?
    scope
  end
end
