module AuthenticationHelper
  def login_as(user)
    post login_as_path, params: { user_id: user.id }
  end
end

module SystemAuthenticationHelper
  def login_as(user)
    visit login_path
    click_button "#{user.name}（#{user.role_label}）としてログイン"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
  config.include SystemAuthenticationHelper, type: :system

  # Auto-login as admin for request specs (unless explicitly testing auth)
  config.before(:each, type: :request) do |example|
    unless example.metadata[:skip_auth]
      @current_test_user ||= create(:user, :admin)
      login_as(@current_test_user)
    end
  end

  # Auto-login as admin for system specs (unless explicitly testing auth)
  config.before(:each, type: :system) do |example|
    unless example.metadata[:skip_auth]
      @current_test_user ||= create(:user, :admin)
      login_as(@current_test_user)
    end
  end
end
