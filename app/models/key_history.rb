class KeyHistory < ApplicationRecord
  belongs_to :key
  belongs_to :tenant, optional: true

  enum :action, { issued: 0, returned: 1, lost_reported: 2, replaced: 3 }

  validates :action, presence: true
  validates :acted_on, presence: true

  def action_label
    return unless action
    I18n.t("activerecord.enums.key_history.action.#{self.action}")
  end
end
