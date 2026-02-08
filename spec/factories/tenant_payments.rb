FactoryBot.define do
  factory :tenant_payment do
    contract
    due_date { Date.new(2024, 5, 27) }
    amount { 85_000 }
    paid_amount { nil }
    paid_date { nil }
    status { :unpaid }
    payment_method { nil }
    notes { "" }
  end
end
