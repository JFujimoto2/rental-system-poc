FactoryBot.define do
  factory :building do
    name { "サンプルマンション" }
    address { "東京都渋谷区1-1-1" }
    building_type { "RC" }
    floors { 5 }
    built_year { 2010 }
    nearest_station { "渋谷駅" }
  end
end
