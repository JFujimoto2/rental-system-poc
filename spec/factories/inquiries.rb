FactoryBot.define do
  factory :inquiry do
    room
    tenant
    category { :repair }
    priority { :normal }
    status { :received }
    title { "水漏れ修繕依頼" }
    received_on { Date.current }
  end
end
