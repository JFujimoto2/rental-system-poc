require "csv"

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?
    redirect_to login_path, alert: "ログインしてください。"
  end

  def authorize_master_management!
    return if current_user&.can_manage_master?
    redirect_to root_path, alert: "この操作を行う権限がありません。"
  end

  def authorize_payment_operations!
    return if current_user&.can_operate_payments?
    redirect_to root_path, alert: "この操作を行う権限がありません。"
  end

  def authorize_user_management!
    return if current_user&.can_manage_users?
    redirect_to root_path, alert: "この操作を行う権限がありません。"
  end
end
