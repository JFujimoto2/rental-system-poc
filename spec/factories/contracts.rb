FactoryBot.define do
  factory :contract do
    room
    tenant
    master_lease { nil }
    lease_type { :ordinary }
    start_date { Date.new(2024, 4, 1) }
    end_date { Date.new(2026, 3, 31) }
    rent { 85_000 }
    management_fee { 5_000 }
    deposit { 170_000 }
    key_money { 85_000 }
    renewal_fee { 85_000 }
    status { :active }
    notes { "" }
  end
end
