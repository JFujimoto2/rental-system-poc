FactoryBot.define do
  factory :key_history do
    key
    action { :issued }
    acted_on { Date.current }
  end
end
