FactoryBot.define do
  factory :owner_payment do
    master_lease
    target_month { Date.new(2024, 5, 1) }
    guaranteed_amount { 500_000 }
    deduction { 0 }
    net_amount { 500_000 }
    status { :unpaid }
    paid_date { nil }
    notes { "" }
  end
end
