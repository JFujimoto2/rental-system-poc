FactoryBot.define do
  factory :approval do
    association :approvable, factory: :contract
    association :requester, factory: :user, role: :operator
    approver { nil }
    status { :pending }
    requested_at { Time.current }
  end
end
