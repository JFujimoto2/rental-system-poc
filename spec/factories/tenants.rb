FactoryBot.define do
  factory :tenant do
    name { "山田 太郎" }
    name_kana { "ヤマダ タロウ" }
    phone { "090-1234-5678" }
    email { "yamada@example.com" }
    postal_code { "150-0001" }
    address { "東京都渋谷区神宮前1-1-1" }
    emergency_contact { "090-8765-4321" }
    notes { "" }
  end
end
