class User < ApplicationRecord
  enum :role, { admin: 0, manager: 1, operator: 2, viewer: 3 }

  validates :provider, presence: true
  validates :uid, presence: true
  validates :name, presence: true
  validates :email, presence: true
  validates :role, presence: true

  def self.find_or_create_from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.name = auth.info.name
    user.email = auth.info.email
    user.role ||= :viewer
    user.save!
    user
  end

  def role_label
    return unless role
    I18n.t("activerecord.enums.user.role.#{role}")
  end

  def can_manage_users?
    admin?
  end

  def can_manage_master?
    admin? || manager?
  end

  def can_operate_payments?
    admin? || manager? || operator?
  end
end
