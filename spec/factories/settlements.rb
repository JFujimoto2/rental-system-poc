FactoryBot.define do
  factory :settlement do
    contract
    settlement_type { :tenant_rent }
    termination_date { Date.new(2024, 6, 30) }
    status { :draft }
    notes { "" }
  end
end
