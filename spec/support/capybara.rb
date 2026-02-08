require "capybara/playwright"

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.prepend_before(:each, type: :system) do
    driven_by :playwright, options: { headless: true, browser_type: :chromium }
  end
end
