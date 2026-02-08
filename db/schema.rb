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

ActiveRecord::Schema[8.1].define(version: 2026_02_08_140806) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "approvals", force: :cascade do |t|
    t.bigint "approvable_id", null: false
    t.string "approvable_type", null: false
    t.bigint "approver_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "decided_at"
    t.datetime "requested_at"
    t.bigint "requester_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["approvable_type", "approvable_id"], name: "index_approvals_on_approvable"
    t.index ["approver_id"], name: "index_approvals_on_approver_id"
    t.index ["requester_id"], name: "index_approvals_on_requester_id"
  end

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

  create_table "constructions", force: :cascade do |t|
    t.integer "actual_cost"
    t.date "actual_end_date"
    t.date "actual_start_date"
    t.integer "construction_type"
    t.integer "cost_bearer"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "estimated_cost"
    t.text "notes"
    t.bigint "room_id", null: false
    t.date "scheduled_end_date"
    t.date "scheduled_start_date"
    t.integer "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.index ["room_id"], name: "index_constructions_on_room_id"
    t.index ["vendor_id"], name: "index_constructions_on_vendor_id"
  end

  create_table "contract_renewals", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.datetime "created_at", null: false
    t.integer "current_rent"
    t.bigint "new_contract_id"
    t.text "notes"
    t.integer "proposed_rent"
    t.date "renewal_date"
    t.integer "renewal_fee"
    t.integer "status"
    t.date "tenant_notified_on"
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_renewals_on_contract_id"
    t.index ["new_contract_id"], name: "index_contract_renewals_on_new_contract_id"
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

  create_table "inquiries", force: :cascade do |t|
    t.bigint "assigned_user_id"
    t.integer "category"
    t.bigint "construction_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.text "notes"
    t.integer "priority"
    t.date "received_on"
    t.date "resolved_on"
    t.text "response"
    t.bigint "room_id"
    t.integer "status"
    t.bigint "tenant_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_inquiries_on_assigned_user_id"
    t.index ["construction_id"], name: "index_inquiries_on_construction_id"
    t.index ["room_id"], name: "index_inquiries_on_room_id"
    t.index ["tenant_id"], name: "index_inquiries_on_tenant_id"
  end

  create_table "insurances", force: :cascade do |t|
    t.bigint "building_id"
    t.integer "coverage_amount"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.integer "insurance_type"
    t.text "notes"
    t.string "policy_number"
    t.integer "premium"
    t.string "provider"
    t.bigint "room_id"
    t.date "start_date"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_insurances_on_building_id"
    t.index ["room_id"], name: "index_insurances_on_room_id"
  end

  create_table "key_histories", force: :cascade do |t|
    t.date "acted_on"
    t.integer "action"
    t.datetime "created_at", null: false
    t.bigint "key_id", null: false
    t.text "notes"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["key_id"], name: "index_key_histories_on_key_id"
    t.index ["tenant_id"], name: "index_key_histories_on_tenant_id"
  end

  create_table "keys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key_number"
    t.integer "key_type"
    t.text "notes"
    t.bigint "room_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_keys_on_room_id"
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

  create_table "vendors", force: :cascade do |t|
    t.string "address"
    t.string "contact_person"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "approvals", "users", column: "approver_id"
  add_foreign_key "approvals", "users", column: "requester_id"
  add_foreign_key "buildings", "owners"
  add_foreign_key "constructions", "rooms"
  add_foreign_key "constructions", "vendors"
  add_foreign_key "contract_renewals", "contracts"
  add_foreign_key "contract_renewals", "contracts", column: "new_contract_id"
  add_foreign_key "contracts", "master_leases"
  add_foreign_key "contracts", "rooms"
  add_foreign_key "contracts", "tenants"
  add_foreign_key "exemption_periods", "master_leases"
  add_foreign_key "exemption_periods", "rooms"
  add_foreign_key "inquiries", "constructions"
  add_foreign_key "inquiries", "rooms"
  add_foreign_key "inquiries", "tenants"
  add_foreign_key "inquiries", "users", column: "assigned_user_id"
  add_foreign_key "insurances", "buildings"
  add_foreign_key "insurances", "rooms"
  add_foreign_key "key_histories", "keys"
  add_foreign_key "key_histories", "tenants"
  add_foreign_key "keys", "rooms"
  add_foreign_key "master_leases", "buildings"
  add_foreign_key "master_leases", "owners"
  add_foreign_key "owner_payments", "master_leases"
  add_foreign_key "rent_revisions", "master_leases"
  add_foreign_key "rooms", "buildings"
  add_foreign_key "settlements", "contracts"
  add_foreign_key "tenant_payments", "contracts"
end
