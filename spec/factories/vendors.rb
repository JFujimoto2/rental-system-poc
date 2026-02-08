FactoryBot.define do
  factory :vendor do
    name { "テスト工事業者" }
    phone { "03-1234-5678" }
    email { "vendor@example.com" }
    address { "東京都新宿区1-1-1" }
    contact_person { "山田太郎" }
  end
end
