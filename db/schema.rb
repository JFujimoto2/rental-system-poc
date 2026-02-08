# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_08_124959) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "buildings", force: :cascade do |t|
    t.string "address"
    t.string "building_type"
    t.integer "built_year"
    t.datetime "created_at", null: false
    t.integer "floors"
    t.string "name"
    t.string "nearest_station"
    t.text "notes"
    t.bigint "owner_id"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_buildings_on_owner_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "deposit"
    t.date "end_date"
    t.integer "key_money"
    t.integer "lease_type"
    t.integer "management_fee"
    t.bigint "master_lease_id"
    t.text "notes"
    t.integer "renewal_fee"
    t.integer "rent"
    t.bigint "room_id", null: false
    t.date "start_date"
    t.integer "status"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["master_lease_id"], name: "index_contracts_on_master_lease_id"
    t.index ["room_id"], name: "index_contracts_on_room_id"
    t.index ["tenant_id"], name: "index_contracts_on_tenant_id"
  end

  create_table "exemption_periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "master_lease_id", null: false
    t.string "reason"
    t.bigint "room_id"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["master_lease_id"], name: "index_exemption_periods_on_master_lease_id"
    t.index ["room_id"], name: "index_exemption_periods_on_room_id"
  end

  create_table "master_leases", force: :cascade do |t|
    t.bigint "building_id", null: false
    t.integer "contract_type"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.integer "guaranteed_rent"
    t.decimal "management_fee_rate"
    t.text "notes"
    t.bigint "owner_id", null: false
    t.integer "rent_review_cycle"
    t.date "start_date"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_master_leases_on_building_id"
    t.index ["owner_id"], name: "index_master_leases_on_owner_id"
  end

  create_table "owner_payments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "deduction"
    t.integer "guaranteed_amount"
    t.bigint "master_lease_id", null: false
    t.integer "net_amount"
    t.text "notes"
    t.date "paid_date"
    t.integer "status"
    t.date "target_month"
    t.datetime "updated_at", null: false
    t.index ["master_lease_id"], name: "index_owner_payments_on_master_lease_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "account_holder"
    t.string "account_number"
    t.string "account_type"
    t.string "address"
    t.string "bank_branch"
    t.string "bank_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "name_kana"
    t.text "notes"
    t.string "phone"
    t.string "postal_code"
    t.datetime "updated_at", null: false
  end

  create_table "rent_revisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "master_lease_id", null: false
    t.integer "new_rent"
    t.text "notes"
    t.integer "old_rent"
    t.date "revision_date"
    t.datetime "updated_at", null: false
    t.index ["master_lease_id"], name: "index_rent_revisions_on_master_lease_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.decimal "area"
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.integer "floor"
    t.text "notes"
    t.integer "rent"
    t.string "room_number"
    t.string "room_type"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_rooms_on_building_id"
  end

  create_table "settlements", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.datetime "created_at", null: false
    t.integer "daily_rent"
    t.integer "days_count"
    t.integer "deposit_amount"
    t.text "notes"
    t.integer "other_deductions"
    t.integer "prorated_rent"
    t.integer "refund_amount"
    t.integer "restoration_cost"
    t.integer "settlement_type"
    t.integer "status"
    t.date "termination_date"
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_settlements_on_contract_id"
  end

  create_table "tenant_payments", force: :cascade do |t|
    t.integer "amount"
    t.bigint "contract_id", null: false
    t.datetime "created_at", null: false
    t.date "due_date"
    t.text "notes"
    t.integer "paid_amount"
    t.date "paid_date"
    t.integer "payment_method"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_tenant_payments_on_contract_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "emergency_contact"
    t.string "name"
    t.string "name_kana"
    t.text "notes"
    t.string "phone"
    t.string "postal_code"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "provider"
    t.integer "role"
    t.string "uid"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "buildings", "owners"
  add_foreign_key "contracts", "master_leases"
  add_foreign_key "contracts", "rooms"
  add_foreign_key "contracts", "tenants"
  add_foreign_key "exemption_periods", "master_leases"
  add_foreign_key "exemption_periods", "rooms"
  add_foreign_key "master_leases", "buildings"
  add_foreign_key "master_leases", "owners"
  add_foreign_key "owner_payments", "master_leases"
  add_foreign_key "rent_revisions", "master_leases"
  add_foreign_key "rooms", "buildings"
  add_foreign_key "settlements", "contracts"
  add_foreign_key "tenant_payments", "contracts"
end
