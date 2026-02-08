FactoryBot.define do
  factory :key do
    room
    key_type { :main }
    status { :in_stock }
    key_number { "K-001" }
  end
end
