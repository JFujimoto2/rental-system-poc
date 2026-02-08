FactoryBot.define do
  factory :contract_renewal do
    contract
    status { :pending }
    current_rent { 80000 }
  end
end
