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

# ----- 業者（Vendor） -----
vendors_data = [
  { name: "東京リフォーム工業",     phone: "03-1111-0001", email: "info@tokyo-reform.example.com",   address: "東京都新宿区西新宿1-1-1", contact_person: "佐々木 健太", notes: "原状回復メイン" },
  { name: "関西メンテナンス",       phone: "06-2222-0002", email: "info@kansai-mente.example.com",   address: "大阪府大阪市北区堂島1-2-3", contact_person: "岡田 美和", notes: "設備交換・修繕" },
  { name: "中部設備サービス",       phone: "052-3333-0003", email: "info@chubu-setsubi.example.com", address: "愛知県名古屋市中村区椿町4-5", contact_person: "山本 剛", notes: "エアコン・水回り専門" },
  { name: "九州ハウスクリーン",     phone: "092-4444-0004", email: "info@kyushu-clean.example.com",  address: "福岡県福岡市博多区博多駅南6-7", contact_person: "川口 真由美" },
  { name: "北海道リノベーション",   phone: "011-5555-0005", email: "info@hokkaido-reno.example.com", address: "北海道札幌市中央区北3条西8-9", contact_person: "石田 大輔", notes: "リノベーション・大規模修繕" }
]
vendors = vendors_data.map { |attrs| Vendor.create!(attrs) }
puts "業者を作成しました（#{vendors.size}社）"

# ----- 工事（Construction） -----
construction_count = 0
all_rooms = Room.all.to_a

# 退去予定部屋に原状回復工事
Room.where(status: :notice).each do |room|
  Construction.create!(
    room: room,
    vendor: vendors[0],
    construction_type: :restoration,
    status: :ordered,
    title: "#{room.room_number}号室 退去後原状回復",
    description: "クロス張替え、ハウスクリーニング",
    estimated_cost: rand(15..40) * 10_000,
    scheduled_start_date: Date.new(2025, 3, 1),
    scheduled_end_date: Date.new(2025, 3, 15),
    cost_bearer: :company
  )
  construction_count += 1
end

# 各地域の建物から数件の修繕・設備交換工事
[
  { room: all_rooms[0], vendor: vendors[0], type: :repair, status: :completed, title: "101号室 浴室水栓交換", est: 35_000, act: 33_000,
    s_start: "2024-11-10", s_end: "2024-11-10", a_start: "2024-11-10", a_end: "2024-11-10", bearer: :company },
  { room: all_rooms[1], vendor: vendors[0], type: :equipment, status: :completed, title: "102号室 エアコン交換", est: 120_000, act: 115_000,
    s_start: "2024-10-01", s_end: "2024-10-03", a_start: "2024-10-01", a_end: "2024-10-02", bearer: :owner },
  { room: all_rooms[5], vendor: vendors[1], type: :repair, status: :in_progress, title: "201号室 給湯器交換", est: 180_000,
    s_start: "2025-02-01", s_end: "2025-02-05", a_start: "2025-02-01", bearer: :owner },
  { room: all_rooms[10], vendor: vendors[2], type: :renovation, status: :draft, title: "301号室 フルリノベーション", est: 2_500_000,
    s_start: "2025-04-01", s_end: "2025-05-31", bearer: :company, desc: "間取り変更（2DK→1LDK）、水回り全交換" },
  { room: all_rooms[15], vendor: vendors[3], type: :repair, status: :completed, title: "102号室 クロス部分張替え", est: 45_000, act: 42_000,
    s_start: "2024-12-15", s_end: "2024-12-16", a_start: "2024-12-15", a_end: "2024-12-15", bearer: :tenant },
  { room: all_rooms[20], vendor: vendors[4], type: :equipment, status: :invoiced, title: "201号室 インターホン交換", est: 85_000, act: 85_000,
    s_start: "2025-01-10", s_end: "2025-01-10", a_start: "2025-01-10", a_end: "2025-01-10", bearer: :company }
].each do |data|
  next unless data[:room]
  Construction.create!(
    room: data[:room],
    vendor: data[:vendor],
    construction_type: data[:type],
    status: data[:status],
    title: data[:title],
    description: data[:desc],
    estimated_cost: data[:est],
    actual_cost: data[:act],
    scheduled_start_date: data[:s_start],
    scheduled_end_date: data[:s_end],
    actual_start_date: data[:a_start],
    actual_end_date: data[:a_end],
    cost_bearer: data[:bearer]
  )
  construction_count += 1
end
puts "工事を作成しました（#{construction_count}件）"

# ----- 契約更新（ContractRenewal） -----
cr_count = 0
active_contracts = contracts.select(&:active?)

# 更新完了済み
if active_contracts.size >= 1
  ContractRenewal.create!(
    contract: active_contracts[0],
    status: :renewed,
    renewal_date: Date.new(2025, 1, 15),
    current_rent: active_contracts[0].rent,
    proposed_rent: (active_contracts[0].rent * 1.03).round(-3),
    renewal_fee: active_contracts[0].rent,
    tenant_notified_on: Date.new(2024, 10, 1)
  )
  cr_count += 1
end

# 交渉中
if active_contracts.size >= 2
  ContractRenewal.create!(
    contract: active_contracts[1],
    status: :negotiating,
    renewal_date: Date.new(2025, 4, 1),
    current_rent: active_contracts[1].rent,
    proposed_rent: (active_contracts[1].rent * 1.05).round(-3),
    renewal_fee: active_contracts[1].rent,
    tenant_notified_on: Date.new(2025, 1, 10),
    notes: "賃料増額について入居者と交渉中"
  )
  cr_count += 1
end

# 通知済
if active_contracts.size >= 3
  ContractRenewal.create!(
    contract: active_contracts[2],
    status: :notified,
    renewal_date: Date.new(2025, 7, 1),
    current_rent: active_contracts[2].rent,
    proposed_rent: active_contracts[2].rent,
    renewal_fee: active_contracts[2].rent,
    tenant_notified_on: Date.new(2025, 2, 1)
  )
  cr_count += 1
end

# 未着手
if active_contracts.size >= 4
  ContractRenewal.create!(
    contract: active_contracts[3],
    status: :pending,
    renewal_date: Date.new(2025, 10, 1),
    current_rent: active_contracts[3].rent
  )
  cr_count += 1
end

# 辞退
if active_contracts.size >= 5
  ContractRenewal.create!(
    contract: active_contracts[4],
    status: :declined,
    renewal_date: Date.new(2025, 3, 31),
    current_rent: active_contracts[4].rent,
    proposed_rent: (active_contracts[4].rent * 1.02).round(-3),
    renewal_fee: active_contracts[4].rent,
    tenant_notified_on: Date.new(2024, 12, 15),
    notes: "入居者都合により更新辞退。退去手続きへ移行。"
  )
  cr_count += 1
end
puts "契約更新を作成しました（#{cr_count}件）"

# ----- 問い合わせ（Inquiry） -----
users = User.all.to_a
operator_user = users.find { |u| u.operator? } || users.first
completed_constructions = Construction.where(status: :completed).to_a

inquiries_data = [
  { room: all_rooms[0], tenant: tenants[0], category: :repair,    priority: :high,   status: :completed,   title: "浴室水栓から水漏れ",           received_on: "2024-11-01", resolved_on: "2024-11-10",
    description: "浴室の水栓から常時水が漏れている。早急に修理をお願いしたい。", response: "水栓交換で対応完了。", construction: completed_constructions[0] },
  { room: all_rooms[1], tenant: tenants[1], category: :repair,    priority: :normal,  status: :closed,      title: "エアコンが動かない",           received_on: "2024-09-15", resolved_on: "2024-10-02",
    description: "リビングのエアコンが起動しない。リモコンの電池は交換済み。", response: "経年劣化のため本体交換で対応。", construction: completed_constructions[1] },
  { room: all_rooms[5], tenant: tenants[2], category: :noise,     priority: :high,    status: :in_progress, title: "上階からの騒音",               received_on: "2025-01-20",
    description: "深夜（23時以降）に上階から足音や物音が頻繁に聞こえる。", response: "上階入居者に注意文書を配布済み。経過観察中。" },
  { room: all_rooms[10], tenant: tenants[4], category: :leak,     priority: :urgent,  status: :assigned,    title: "天井から漏水",                 received_on: "2025-02-05",
    description: "リビングの天井から水が滴っている。上階の配管の問題か。" },
  { room: all_rooms[15], tenant: tenants[6], category: :complaint, priority: :normal,  status: :completed,   title: "共用部の清掃について",         received_on: "2024-12-01", resolved_on: "2024-12-10",
    description: "共用廊下の清掃頻度が減っている気がする。", response: "清掃業者に確認し、週2回→週3回に変更。" },
  { room: nil,           tenant: nil,        category: :question,  priority: :low,     status: :closed,      title: "駐車場の空き状況について",     received_on: "2024-11-20", resolved_on: "2024-11-21",
    description: "駐車場の空きがあれば契約したい。", response: "現在満車。空き次第ご連絡する旨回答。" },
  { room: all_rooms[20], tenant: tenants[8], category: :repair,    priority: :normal,  status: :received,    title: "玄関ドアの建付け不良",         received_on: "2025-02-07",
    description: "玄関ドアの閉まりが悪く、隙間風が入る。" },
  { room: all_rooms[3],  tenant: tenants[0], category: :question,  priority: :low,     status: :completed,   title: "更新手続きの流れを知りたい",   received_on: "2025-01-05", resolved_on: "2025-01-06",
    description: "来年の契約更新の時期と手続きについて教えてほしい。", response: "更新日3ヶ月前にご案内をお送りする旨ご説明。" }
]

inquiry_count = 0
inquiries_data.each do |data|
  assigned = data[:status].in?([ :assigned, :in_progress, :completed, :closed ]) ? operator_user : nil
  Inquiry.create!(
    room: data[:room],
    tenant: data[:tenant],
    assigned_user: assigned,
    construction: data[:construction],
    category: data[:category],
    priority: data[:priority],
    status: data[:status],
    title: data[:title],
    description: data[:description],
    response: data[:response],
    received_on: data[:received_on],
    resolved_on: data[:resolved_on]
  )
  inquiry_count += 1
end
puts "問い合わせを作成しました（#{inquiry_count}件）"

# ----- 鍵（Key）+ 鍵履歴（KeyHistory） -----
key_count = 0
key_history_count = 0

# occupied 部屋に本鍵+合鍵（貸出中）
Room.where(status: :occupied).limit(15).each_with_index do |room, i|
  tenant = room.contracts.find_by(status: :active)&.tenant

  # 本鍵
  main_key = Key.create!(room: room, key_type: :main, key_number: "M-#{room.building_id}-#{room.room_number}", status: :issued)
  key_count += 1
  if tenant
    KeyHistory.create!(key: main_key, tenant: tenant, action: :issued, acted_on: Date.new(2024, [ 1, 4, 7, 10 ].sample, 1), notes: "入居時貸出")
    key_history_count += 1
  end

  # 合鍵
  dup_key = Key.create!(room: room, key_type: :duplicate, key_number: "D-#{room.building_id}-#{room.room_number}", status: :issued)
  key_count += 1
  if tenant
    KeyHistory.create!(key: dup_key, tenant: tenant, action: :issued, acted_on: Date.new(2024, [ 1, 4, 7, 10 ].sample, 1), notes: "入居時貸出")
    key_history_count += 1
  end

  # スペア（在庫）
  Key.create!(room: room, key_type: :spare, key_number: "S-#{room.building_id}-#{room.room_number}", status: :in_stock)
  key_count += 1
end

# vacant 部屋に本鍵+合鍵（在庫）+ 返却履歴
Room.where(status: :vacant).limit(5).each do |room|
  prev_tenant = room.contracts.find_by(status: :terminated)&.tenant || tenants.sample

  main_key = Key.create!(room: room, key_type: :main, key_number: "M-#{room.building_id}-#{room.room_number}", status: :in_stock)
  key_count += 1
  # 貸出→返却の履歴
  KeyHistory.create!(key: main_key, tenant: prev_tenant, action: :issued, acted_on: Date.new(2022, 4, 1), notes: "入居時貸出")
  KeyHistory.create!(key: main_key, tenant: prev_tenant, action: :returned, acted_on: Date.new(2024, 3, 31), notes: "退去時返却")
  key_history_count += 2

  Key.create!(room: room, key_type: :duplicate, key_number: "D-#{room.building_id}-#{room.room_number}", status: :in_stock)
  key_count += 1
end

# 紛失鍵の例
if (lost_room = Room.where(status: :occupied).offset(15).first)
  lost_tenant = lost_room.contracts.find_by(status: :active)&.tenant || tenants.sample
  lost_key = Key.create!(room: lost_room, key_type: :main, key_number: "M-#{lost_room.building_id}-#{lost_room.room_number}-OLD", status: :lost)
  key_count += 1
  KeyHistory.create!(key: lost_key, tenant: lost_tenant, action: :issued, acted_on: Date.new(2024, 4, 1))
  KeyHistory.create!(key: lost_key, tenant: lost_tenant, action: :lost_reported, acted_on: Date.new(2025, 1, 15), notes: "入居者より紛失届")
  key_history_count += 2

  # 交換した新鍵
  new_key = Key.create!(room: lost_room, key_type: :main, key_number: "M-#{lost_room.building_id}-#{lost_room.room_number}", status: :issued)
  key_count += 1
  KeyHistory.create!(key: new_key, tenant: lost_tenant, action: :replaced, acted_on: Date.new(2025, 1, 20), notes: "紛失に伴う鍵交換")
  KeyHistory.create!(key: new_key, tenant: lost_tenant, action: :issued, acted_on: Date.new(2025, 1, 20), notes: "交換後貸出")
  key_history_count += 2
end

# オートロック・郵便受けキー
buildings.first(3).each do |building|
  building_rooms = rooms_by_building[building.id] || []
  building_rooms.first(2).each do |room|
    Key.create!(room: room, key_type: :auto_lock, key_number: "AL-#{building.id}", status: :issued)
    Key.create!(room: room, key_type: :mailbox, key_number: "MB-#{building.id}-#{room.room_number}", status: :issued)
    key_count += 2
  end
end
puts "鍵を作成しました（#{key_count}本）"
puts "鍵履歴を作成しました（#{key_history_count}件）"

# ----- 保険（Insurance） -----
insurance_count = 0

# 建物単位の火災保険・地震保険
buildings.each_with_index do |building, i|
  # 火災保険（全建物）
  Insurance.create!(
    building: building,
    insurance_type: :fire,
    status: i < 8 ? :active : :expiring_soon,
    policy_number: "FI-#{format('%04d', i + 1)}",
    provider: %w[東京海上日動 損保ジャパン 三井住友海上 あいおいニッセイ同和][i % 4],
    coverage_amount: building.floors * 50_000_000,
    premium: building.floors * 120_000,
    start_date: Date.new(2024, 4, 1),
    end_date: i < 8 ? Date.new(2026, 3, 31) : Date.new(2025, 3, 15)
  )
  insurance_count += 1

  # 地震保険（一部の建物）
  next unless i < 6
  Insurance.create!(
    building: building,
    insurance_type: :earthquake,
    status: :active,
    policy_number: "EQ-#{format('%04d', i + 1)}",
    provider: %w[東京海上日動 損保ジャパン 三井住友海上][i % 3],
    coverage_amount: building.floors * 25_000_000,
    premium: building.floors * 60_000,
    start_date: Date.new(2024, 4, 1),
    end_date: Date.new(2026, 3, 31)
  )
  insurance_count += 1
end

# 部屋単位の借家人賠償保険（occupied 部屋の一部）
Room.where(status: :occupied).limit(10).each_with_index do |room, i|
  status = i < 8 ? :active : :expired
  Insurance.create!(
    room: room,
    insurance_type: :tenant_liability,
    status: status,
    policy_number: "TL-#{format('%04d', i + 1)}",
    provider: %w[日新火災 全労済 県民共済 楽天損保][i % 4],
    coverage_amount: 20_000_000,
    premium: 15_000,
    start_date: status == :active ? Date.new(2024, 4, 1) : Date.new(2022, 4, 1),
    end_date: status == :active ? Date.new(2026, 3, 31) : Date.new(2024, 3, 31)
  )
  insurance_count += 1
end

# 施設賠償保険（一部の建物）
buildings.first(3).each_with_index do |building, i|
  Insurance.create!(
    building: building,
    insurance_type: :facility_liability,
    status: :active,
    policy_number: "FL-#{format('%04d', i + 1)}",
    provider: %w[東京海上日動 損保ジャパン 三井住友海上][i],
    coverage_amount: 100_000_000,
    premium: 250_000,
    start_date: Date.new(2024, 7, 1),
    end_date: Date.new(2026, 6, 30)
  )
  insurance_count += 1
end
puts "保険を作成しました（#{insurance_count}件）"

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
puts "  業者:               #{Vendor.count}社"
puts "  工事:               #{Construction.count}件"
puts "  契約更新:           #{ContractRenewal.count}件"
puts "  問い合わせ:         #{Inquiry.count}件"
puts "  鍵:                 #{Key.count}本"
puts "  鍵履歴:             #{KeyHistory.count}件"
puts "  保険:               #{Insurance.count}件"
