FactoryBot.define do
  factory :master_lease do
    owner
    building
    contract_type { :sublease }
    start_date { Date.new(2024, 4, 1) }
    end_date { Date.new(2026, 3, 31) }
    guaranteed_rent { 500_000 }
    rent_review_cycle { 24 }
    status { :active }
  end
end
