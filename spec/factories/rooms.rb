FactoryBot.define do
  factory :room do
    building
    room_number { "101" }
    floor { 1 }
    area { 25.5 }
    rent { 80_000 }
    status { :vacant }
    room_type { "1K" }
  end
end
