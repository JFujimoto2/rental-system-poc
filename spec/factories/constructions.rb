FactoryBot.define do
  factory :construction do
    room
    vendor
    construction_type { :restoration }
    status { :draft }
    title { "原状回復工事" }
    estimated_cost { 300000 }
  end
end
