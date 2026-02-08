FactoryBot.define do
  factory :insurance do
    building
    insurance_type { :fire }
    status { :active }
    provider { "東京海上日動" }
    policy_number { "POL-001" }
    premium { 50000 }
    coverage_amount { 100000000 }
    start_date { Date.current }
    end_date { 1.year.from_now.to_date }
  end
end
