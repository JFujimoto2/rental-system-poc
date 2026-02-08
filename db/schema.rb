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

ActiveRecord::Schema[8.1].define(version: 2026_02_08_090053) do
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

  add_foreign_key "buildings", "owners"
  add_foreign_key "rooms", "buildings"
end
