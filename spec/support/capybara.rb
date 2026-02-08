require "capybara/playwright"

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :playwright, options: { headless: true, browser_type: :chromium }
  end
end
