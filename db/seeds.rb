# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 開発用ユーザー（各ロール1名ずつ）
if Rails.env.local?
  [
    { provider: "dev", uid: "dev-admin",    name: "管理者",         email: "admin@example.com",    role: :admin },
    { provider: "dev", uid: "dev-manager",  name: "マネージャー",   email: "manager@example.com",  role: :manager },
    { provider: "dev", uid: "dev-operator", name: "オペレーター",   email: "operator@example.com", role: :operator },
    { provider: "dev", uid: "dev-viewer",   name: "閲覧者",         email: "viewer@example.com",   role: :viewer }
  ].each do |attrs|
    User.find_or_create_by!(provider: attrs[:provider], uid: attrs[:uid]) do |user|
      user.name  = attrs[:name]
      user.email = attrs[:email]
      user.role  = attrs[:role]
    end
  end
  puts "開発用ユーザーを作成しました（4名）"
end

# === テストデータ（開発環境のみ） ===
return unless Rails.env.local?
return if Owner.exists? # 冪等性: 既にデータがあればスキップ

# ----- オーナー -----
owners = [
  { name: "田中 太郎",   name_kana: "タナカ タロウ",     phone: "03-1111-2222", email: "tanaka@example.com",
    postal_code: "150-0001", address: "東京都渋谷区神宮前1-1-1",
    bank_name: "みずほ銀行", bank_branch: "渋谷支店", account_type: "普通", account_number: "1234567", account_holder: "タナカ タロウ" },
  { name: "鈴木 花子",   name_kana: "スズキ ハナコ",     phone: "06-3333-4444", email: "suzuki@example.com",
    postal_code: "530-0001", address: "大阪府大阪市北区梅田2-2-2",
    bank_name: "三菱UFJ銀行", bank_branch: "梅田支店", account_type: "普通", account_number: "7654321", account_holder: "スズキ ハナコ" },
  { name: "佐藤 一郎",   name_kana: "サトウ イチロウ",   phone: "052-5555-6666", email: "sato@example.com",
    postal_code: "460-0008", address: "愛知県名古屋市中区栄3-3-3",
    bank_name: "三井住友銀行", bank_branch: "名古屋支店", account_type: "当座", account_number: "1112233", account_holder: "サトウ イチロウ" },
  { name: "高橋 美咲",   name_kana: "タカハシ ミサキ",   phone: "092-7777-8888", email: "takahashi@example.com",
    postal_code: "810-0001", address: "福岡県福岡市中央区天神4-4-4",
    bank_name: "福岡銀行", bank_branch: "天神支店", account_type: "普通", account_number: "9998877", account_holder: "タカハシ ミサキ" },
  { name: "渡辺 健二",   name_kana: "ワタナベ ケンジ",   phone: "011-9999-0000", email: "watanabe@example.com",
    postal_code: "060-0042", address: "北海道札幌市中央区大通西5-5-5",
    bank_name: "北洋銀行", bank_branch: "札幌支店", account_type: "普通", account_number: "5556677", account_holder: "ワタナベ ケンジ" }
].map { |attrs| Owner.create!(attrs) }
puts "オーナーを作成しました（#{owners.size}名）"

# ----- 建物 -----
buildings_data = [
  { name: "グランドメゾン渋谷",     address: "東京都渋谷区桜丘町10-1",    building_type: "RC",   floors: 10, built_year: 2015, nearest_station: "渋谷駅 徒歩5分",   owner: owners[0] },
  { name: "パークハイツ代々木",     address: "東京都渋谷区代々木2-5-3",    building_type: "SRC",  floors: 15, built_year: 2018, nearest_station: "代々木駅 徒歩3分", owner: owners[0] },
  { name: "サンライズ梅田",         address: "大阪府大阪市北区梅田1-8-6",  building_type: "RC",   floors: 8,  built_year: 2010, nearest_station: "梅田駅 徒歩7分",   owner: owners[1] },
  { name: "リバーサイド難波",       address: "大阪府大阪市浪速区難波中1-2", building_type: "S",    floors: 5,  built_year: 2005, nearest_station: "難波駅 徒歩4分",   owner: owners[1] },
  { name: "栄タワーレジデンス",     address: "愛知県名古屋市中区栄4-16-8",  building_type: "SRC",  floors: 20, built_year: 2020, nearest_station: "栄駅 徒歩2分",     owner: owners[2] },
  { name: "セントラルコート名駅",   address: "愛知県名古屋市中村区名駅3-1", building_type: "RC",   floors: 12, built_year: 2017, nearest_station: "名古屋駅 徒歩6分", owner: owners[2] },
  { name: "天神パレス",             address: "福岡県福岡市中央区天神2-3-1",  building_type: "RC",   floors: 7,  built_year: 2012, nearest_station: "天神駅 徒歩3分",   owner: owners[3] },
  { name: "博多グリーンハイツ",     address: "福岡県福岡市博多区博多駅前3-5", building_type: "S",   floors: 6,  built_year: 2008, nearest_station: "博多駅 徒歩8分",   owner: owners[3] },
  { name: "札幌ノーステラス",       address: "北海道札幌市中央区北1条西4-2",  building_type: "RC",   floors: 9,  built_year: 2019, nearest_station: "大通駅 徒歩4分",   owner: owners[4] },
  { name: "すすきのアーバンコート", address: "北海道札幌市中央区南4条西3-1",  building_type: "SRC",  floors: 11, built_year: 2016, nearest_station: "すすきの駅 徒歩1分", owner: owners[4] }
]
buildings = buildings_data.map { |attrs| Building.create!(attrs) }
puts "建物を作成しました（#{buildings.size}棟）"

# ----- 部屋 -----
room_types = %w[1K 1DK 1LDK 2K 2DK 2LDK 3LDK]
room_count = 0
rooms_by_building = {}

buildings.each do |building|
  num_rooms = rand(4..8)
  rooms = []
  num_rooms.times do |i|
    floor = (i / 3) + 1
    room_num = "#{floor}0#{(i % 3) + 1}"
    type = room_types.sample
    area = rand(200..800) / 10.0
    rent = (area * 3000 + rand(-5000..5000)).round(-3).clamp(40_000, 300_000)
    status = %i[vacant occupied occupied occupied notice].sample

    rooms << Room.create!(
      building: building,
      room_number: room_num,
      floor: floor,
      room_type: type,
      area: area,
      rent: rent,
      status: status
    )
  end
  rooms_by_building[building.id] = rooms
  room_count += rooms.size
end
puts "部屋を作成しました（#{room_count}室）"

# ----- マスターリース -----
ml_data = [
  { owner: owners[0], building: buildings[0], contract_type: :sublease,   start_date: "2023-04-01", end_date: "2025-03-31", guaranteed_rent: 800_000,  rent_review_cycle: 24, status: :active },
  { owner: owners[0], building: buildings[1], contract_type: :management, start_date: "2024-01-01", end_date: "2025-12-31", guaranteed_rent: 1_200_000, rent_review_cycle: 12, status: :active },
  { owner: owners[1], building: buildings[2], contract_type: :sublease,   start_date: "2022-04-01", end_date: "2024-03-31", guaranteed_rent: 600_000,  rent_review_cycle: 24, status: :terminated },
  { owner: owners[1], building: buildings[3], contract_type: :sublease,   start_date: "2024-04-01", end_date: "2026-03-31", guaranteed_rent: 400_000,  rent_review_cycle: 24, status: :active },
  { owner: owners[2], building: buildings[4], contract_type: :management, start_date: "2024-07-01", end_date: "2026-06-30", guaranteed_rent: 1_500_000, rent_review_cycle: 12, status: :active },
  { owner: owners[2], building: buildings[5], contract_type: :sublease,   start_date: "2023-10-01", end_date: "2025-09-30", guaranteed_rent: 700_000,  rent_review_cycle: 24, status: :scheduled_termination },
  { owner: owners[3], building: buildings[6], contract_type: :own,        start_date: "2024-01-01", end_date: nil,          guaranteed_rent: nil,      rent_review_cycle: nil, status: :active },
  { owner: owners[3], building: buildings[7], contract_type: :sublease,   start_date: "2023-01-01", end_date: "2024-12-31", guaranteed_rent: 350_000,  rent_review_cycle: 24, status: :terminated },
  { owner: owners[4], building: buildings[8], contract_type: :management, start_date: "2024-10-01", end_date: "2026-09-30", guaranteed_rent: 900_000,  rent_review_cycle: 12, status: :active },
  { owner: owners[4], building: buildings[9], contract_type: :sublease,   start_date: "2024-04-01", end_date: "2026-03-31", guaranteed_rent: 1_000_000, rent_review_cycle: 24, status: :active }
]
master_leases = ml_data.map { |attrs| MasterLease.create!(attrs) }
puts "マスターリース契約を作成しました（#{master_leases.size}件）"

# ----- 免責期間・賃料改定 -----
ep_count = 0
master_leases.select(&:sublease?).each do |ml|
  ExemptionPeriod.create!(master_lease: ml, start_date: ml.start_date, end_date: ml.start_date + 2.months, reason: "新規契約免責")
  ep_count += 1
end
puts "免責期間を作成しました（#{ep_count}件）"

rr_count = 0
master_leases.select { |ml| ml.active? && ml.guaranteed_rent }.each do |ml|
  RentRevision.create!(master_lease: ml, revision_date: ml.start_date + 2.years, old_rent: ml.guaranteed_rent, new_rent: (ml.guaranteed_rent * 1.03).round(-3))
  rr_count += 1
end
puts "賃料改定を作成しました（#{rr_count}件）"

# ----- 入居者 -----
tenants_data = [
  { name: "山田 太郎",     name_kana: "ヤマダ タロウ",     phone: "090-1111-1111", email: "yamada@example.com",    postal_code: "150-0011", address: "東京都渋谷区東1-1-1",        emergency_contact: "090-1111-0000" },
  { name: "伊藤 美香",     name_kana: "イトウ ミカ",       phone: "080-2222-2222", email: "ito@example.com",       postal_code: "150-0012", address: "東京都渋谷区広尾2-2-2",      emergency_contact: "080-2222-0000" },
  { name: "中村 大輔",     name_kana: "ナカムラ ダイスケ", phone: "070-3333-3333", email: "nakamura@example.com",  postal_code: "530-0011", address: "大阪府大阪市北区大深町3-3-3", emergency_contact: "070-3333-0000" },
  { name: "小林 さくら",   name_kana: "コバヤシ サクラ",   phone: "090-4444-4444", email: "kobayashi@example.com", postal_code: "530-0012", address: "大阪府大阪市北区芝田4-4-4",   emergency_contact: "090-4444-0000" },
  { name: "加藤 翔太",     name_kana: "カトウ ショウタ",   phone: "080-5555-5555", email: "kato@example.com",      postal_code: "460-0011", address: "愛知県名古屋市中区大須5-5-5", emergency_contact: "080-5555-0000" },
  { name: "吉田 愛",       name_kana: "ヨシダ アイ",       phone: "070-6666-6666", email: "yoshida@example.com",   postal_code: "460-0012", address: "愛知県名古屋市中区金山6-6-6", emergency_contact: "070-6666-0000" },
  { name: "松本 健一",     name_kana: "マツモト ケンイチ", phone: "090-7777-7777", email: "matsumoto@example.com", postal_code: "810-0011", address: "福岡県福岡市中央区薬院7-7-7", emergency_contact: "090-7777-0000" },
  { name: "井上 真理",     name_kana: "イノウエ マリ",     phone: "080-8888-8888", email: "inoue@example.com",     postal_code: "810-0012", address: "福岡県福岡市中央区大名8-8-8", emergency_contact: "080-8888-0000" },
  { name: "木村 拓也",     name_kana: "キムラ タクヤ",     phone: "070-9999-9999", email: "kimura@example.com",    postal_code: "060-0011", address: "北海道札幌市中央区南1条9-9-9", emergency_contact: "070-9999-0000" },
  { name: "林 由美子",     name_kana: "ハヤシ ユミコ",     phone: "090-0000-1111", email: "hayashi@example.com",   postal_code: "060-0012", address: "北海道札幌市中央区北2条10-10", emergency_contact: "090-0000-0000" },
  { name: "清水 隆",       name_kana: "シミズ タカシ",     phone: "080-1212-3434", email: "shimizu@example.com",   postal_code: "150-0013", address: "東京都渋谷区恵比寿1-2-3",    emergency_contact: "080-1212-0000" },
  { name: "山口 恵",       name_kana: "ヤマグチ メグミ",   phone: "070-5656-7878", email: "yamaguchi@example.com", postal_code: "530-0013", address: "大阪府大阪市北区中之島4-5-6", emergency_contact: "070-5656-0000" },
  { name: "斎藤 浩二",     name_kana: "サイトウ コウジ",   phone: "090-1234-5678", email: "saito@example.com",     postal_code: "460-0013", address: "愛知県名古屋市中区丸の内7-8-9", emergency_contact: "090-1234-0000" },
  { name: "前田 あかり",   name_kana: "マエダ アカリ",     phone: "080-8765-4321", email: "maeda@example.com",     postal_code: "810-0013", address: "福岡県福岡市中央区赤坂2-3-4", emergency_contact: "080-8765-0000" },
  { name: "藤田 雄大",     name_kana: "フジタ ユウダイ",   phone: "070-2468-1357", email: "fujita@example.com",    postal_code: "060-0013", address: "北海道札幌市中央区大通東5-6-7", emergency_contact: "070-2468-0000" }
]
tenants = tenants_data.map { |attrs| Tenant.create!(attrs) }
puts "入居者を作成しました（#{tenants.size}名）"

# ----- 転貸借契約 -----
occupied_rooms = Room.where(status: :occupied).to_a.shuffle
contract_count = 0
contracts = []

occupied_rooms.each_with_index do |room, i|
  tenant = tenants[i % tenants.size]
  ml = master_leases.find { |m| m.building_id == room.building_id && m.active? }
  lease_type = %i[ordinary ordinary ordinary fixed_term].sample
  start_date = Date.new(2024, [ 1, 4, 7, 10 ].sample, 1)

  contract = Contract.create!(
    room: room,
    tenant: tenant,
    master_lease: ml,
    lease_type: lease_type,
    start_date: start_date,
    end_date: start_date + 2.years,
    rent: room.rent,
    management_fee: (room.rent * 0.05).round(-2),
    deposit: room.rent * 2,
    key_money: room.rent,
    renewal_fee: room.rent,
    status: :active
  )
  contracts << contract
  contract_count += 1
end

# 退去予定の部屋にも契約追加
Room.where(status: :notice).limit(3).each_with_index do |room, i|
  tenant = tenants[(occupied_rooms.size + i) % tenants.size]
  ml = master_leases.find { |m| m.building_id == room.building_id }

  contract = Contract.create!(
    room: room,
    tenant: tenant,
    master_lease: ml,
    lease_type: :ordinary,
    start_date: Date.new(2023, 4, 1),
    end_date: Date.new(2025, 3, 31),
    rent: room.rent,
    management_fee: (room.rent * 0.05).round(-2),
    deposit: room.rent * 2,
    key_money: room.rent,
    renewal_fee: room.rent,
    status: :scheduled_termination
  )
  contracts << contract
  contract_count += 1
end

# 申込中の契約
Room.where(status: :vacant).limit(2).each_with_index do |room, i|
  tenant = tenants.last(2)[i]
  contract = Contract.create!(
    room: room,
    tenant: tenant,
    master_lease: nil,
    lease_type: :fixed_term,
    start_date: Date.new(2025, 4, 1),
    end_date: Date.new(2027, 3, 31),
    rent: room.rent,
    management_fee: (room.rent * 0.05).round(-2),
    deposit: room.rent * 2,
    key_money: room.rent,
    renewal_fee: 0,
    status: :applying
  )
  contracts << contract
  contract_count += 1
end

# 解約済みの契約
2.times do |i|
  room = Room.where(status: :vacant).offset(2 + i).first
  next unless room
  tenant = tenants[i]
  contract = Contract.create!(
    room: room,
    tenant: tenant,
    master_lease: nil,
    lease_type: :ordinary,
    start_date: Date.new(2022, 4, 1),
    end_date: Date.new(2024, 3, 31),
    rent: room.rent,
    management_fee: (room.rent * 0.05).round(-2),
    deposit: room.rent * 2,
    key_money: room.rent,
    renewal_fee: room.rent,
    status: :terminated
  )
  contracts << contract
  contract_count += 1
end
puts "転貸借契約を作成しました（#{contract_count}件）"

# ----- テナント入金 -----
tp_count = 0
payment_methods = %i[transfer direct_debit cash]

contracts.select { |c| c.active? || c.scheduled_termination? }.each do |contract|
  # 過去6ヶ月分の入金（入金済み）
  6.times do |i|
    due = Date.new(2024, 7 + i > 12 ? i - 5 : 7 + i, 27)
    due = due.next_year if 7 + i > 12
    method = payment_methods.sample

    TenantPayment.create!(
      contract: contract,
      due_date: due,
      amount: contract.rent + contract.management_fee,
      paid_amount: contract.rent + contract.management_fee,
      paid_date: due - rand(0..5).days,
      status: :paid,
      payment_method: method
    )
    tp_count += 1
  end

  # 当月分（未入金・一部入金・延滞を混ぜる）
  current_status = %i[unpaid unpaid partial overdue].sample
  paid_amt = case current_status
  when :partial then (contract.rent * 0.5).to_i
  when :paid then contract.rent + contract.management_fee
  else nil
  end
  paid_dt = current_status == :partial ? Date.current - 2.days : nil

  TenantPayment.create!(
    contract: contract,
    due_date: Date.new(2025, 1, 27),
    amount: contract.rent + contract.management_fee,
    paid_amount: paid_amt,
    paid_date: paid_dt,
    status: current_status,
    payment_method: current_status == :partial ? :transfer : nil
  )
  tp_count += 1

  # 来月分（未入金）
  TenantPayment.create!(
    contract: contract,
    due_date: Date.new(2025, 2, 27),
    amount: contract.rent + contract.management_fee,
    paid_amount: nil,
    paid_date: nil,
    status: :unpaid,
    payment_method: nil
  )
  tp_count += 1
end
puts "テナント入金を作成しました（#{tp_count}件）"

# ----- オーナー支払 -----
op_count = 0

master_leases.select { |ml| ml.guaranteed_rent.present? }.each do |ml|
  # 過去6ヶ月分（支払済み）
  6.times do |i|
    month = Date.new(2024, 7 + i > 12 ? i - 5 : 7 + i, 1)
    month = month.next_year if 7 + i > 12
    deduction = [ 0, 0, 0, 10_000, 20_000, 50_000 ].sample

    OwnerPayment.create!(
      master_lease: ml,
      target_month: month,
      guaranteed_amount: ml.guaranteed_rent,
      deduction: deduction,
      net_amount: ml.guaranteed_rent - deduction,
      status: :paid,
      paid_date: month.end_of_month
    )
    op_count += 1
  end

  # 当月分（未払い）
  OwnerPayment.create!(
    master_lease: ml,
    target_month: Date.new(2025, 1, 1),
    guaranteed_amount: ml.guaranteed_rent,
    deduction: 0,
    net_amount: ml.guaranteed_rent,
    status: :unpaid,
    paid_date: nil
  )
  op_count += 1

  # 来月分（未払い）
  OwnerPayment.create!(
    master_lease: ml,
    target_month: Date.new(2025, 2, 1),
    guaranteed_amount: ml.guaranteed_rent,
    deduction: 0,
    net_amount: ml.guaranteed_rent,
    status: :unpaid,
    paid_date: nil
  )
  op_count += 1
end
puts "オーナー支払を作成しました（#{op_count}件）"

puts ""
puts "=== seed 完了 ==="
puts "  オーナー:           #{Owner.count}名"
puts "  建物:               #{Building.count}棟"
puts "  部屋:               #{Room.count}室"
puts "  マスターリース:     #{MasterLease.count}件"
puts "  免責期間:           #{ExemptionPeriod.count}件"
puts "  賃料改定:           #{RentRevision.count}件"
puts "  入居者:             #{Tenant.count}名"
puts "  転貸借契約:         #{Contract.count}件"
puts "  テナント入金:       #{TenantPayment.count}件"
puts "  オーナー支払:       #{OwnerPayment.count}件"
