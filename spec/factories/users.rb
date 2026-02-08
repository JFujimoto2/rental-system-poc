FactoryBot.define do
  factory :user do
    provider { "entra_id" }
    sequence(:uid) { |n| "entra-uid-#{n}" }
    name { "テストユーザー" }
    sequence(:email) { |n| "user#{n}@example.com" }
    role { :viewer }

    trait :admin do
      role { :admin }
      name { "管理者" }
    end

    trait :manager do
      role { :manager }
      name { "マネージャー" }
    end

    trait :operator do
      role { :operator }
      name { "オペレーター" }
    end

    trait :viewer do
      role { :viewer }
      name { "閲覧者" }
    end
  end
end
