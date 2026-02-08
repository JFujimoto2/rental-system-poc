FactoryBot.define do
  factory :rent_revision do
    master_lease
    revision_date { Date.new(2026, 4, 1) }
    old_rent { 500_000 }
    new_rent { 480_000 }
    notes { "市場賃料の下落に伴う改定" }
  end
end
