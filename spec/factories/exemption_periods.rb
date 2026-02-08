FactoryBot.define do
  factory :exemption_period do
    master_lease
    start_date { Date.new(2024, 4, 1) }
    end_date { Date.new(2024, 5, 31) }
    reason { "新築" }
  end
end
