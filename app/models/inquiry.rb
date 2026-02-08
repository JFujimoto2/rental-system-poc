class Inquiry < ApplicationRecord
  belongs_to :room, optional: true
  belongs_to :tenant, optional: true
  belongs_to :assigned_user, class_name: "User", optional: true
  belongs_to :construction, optional: true

  enum :category, { repair: 0, complaint: 1, question: 2, noise: 3, leak: 4, other: 5 }
  enum :priority, { low: 0, normal: 1, high: 2, urgent: 3 }
  enum :status, { received: 0, assigned: 1, in_progress: 2, completed: 3, closed: 4 }

  validates :title, presence: true
  validates :category, presence: true
  validates :status, presence: true

  def self.search(params)
    scope = all
    scope = scope.joins(room: :building).where("buildings.name ILIKE ?", "%#{params[:building_name]}%") if params[:building_name].present?
    scope = scope.joins(:tenant).where("tenants.name ILIKE ?", "%#{params[:tenant_name]}%") if params[:tenant_name].present?
    scope = scope.where(category: params[:category]) if params[:category].present?
    scope = scope.where(priority: params[:priority]) if params[:priority].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope
  end

  def category_label
    return unless category
    I18n.t("activerecord.enums.inquiry.category.#{category}")
  end

  def priority_label
    return unless priority
    I18n.t("activerecord.enums.inquiry.priority.#{priority}")
  end

  def status_label
    return unless status
    I18n.t("activerecord.enums.inquiry.status.#{status}")
  end
end
