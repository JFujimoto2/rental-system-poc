FactoryBot.define do
  factory :owner do
    name { "山田太郎" }
    name_kana { "ヤマダタロウ" }
    phone { "03-1234-5678" }
    email { "yamada@example.com" }
    postal_code { "150-0001" }
    address { "東京都渋谷区神宮前1-1-1" }
    bank_name { "みずほ銀行" }
    bank_branch { "渋谷支店" }
    account_type { "普通" }
    account_number { "1234567" }
    account_holder { "ヤマダタロウ" }
  end
end
