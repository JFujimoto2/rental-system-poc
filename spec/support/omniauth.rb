OmniAuth.config.test_mode = true
OmniAuth.config.silence_get_warning = true

RSpec.configure do |config|
  config.before(:each) do
    OmniAuth.config.mock_auth[:entra_id] = nil
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end
