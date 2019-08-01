# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171031120828) do

  create_table "admin_ips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "ip", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "admin_id", null: false
    t.string "ip", null: false
    t.string "action_name", null: false
    t.string "action_details", limit: 10000, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_logs_on_admin_id"
  end

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 64, null: false
    t.string "password", limit: 32, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prepaid_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code", null: false
    t.string "pin"
    t.bigint "prepaid_type_id", null: false
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_prepaid_codes_on_admin_id"
    t.index ["prepaid_type_id"], name: "index_prepaid_codes_on_prepaid_type_id"
  end

  create_table "prepaid_purchases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id", null: false
    t.bigint "prepaid_code_id", null: false
    t.decimal "purchase_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prepaid_code_id"], name: "index_prepaid_purchases_on_prepaid_code_id"
    t.index ["user_id"], name: "index_prepaid_purchases_on_user_id"
  end

  create_table "prepaid_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.bigint "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reload_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id", null: false
    t.string "transaction_id", null: false
    t.string "transaction_type", null: false
    t.string "comments", limit: 1000
    t.string "approved", limit: 16, null: false
    t.bigint "admin_id"
    t.string "approve_comments", limit: 1000
    t.datetime "approve_time"
    t.decimal "approve_credits", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_reload_requests_on_admin_id"
    t.index ["user_id"], name: "index_reload_requests_on_user_id"
  end

  create_table "user_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id", null: false
    t.string "ip", null: false
    t.string "action_name", null: false
    t.string "action_details", limit: 10000, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_logs_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 64, null: false
    t.string "password", limit: 32, null: false
    t.date "dob", null: false
    t.string "email", null: false
    t.decimal "credits", precision: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "admin_logs", "admins"
  add_foreign_key "prepaid_codes", "admins"
  add_foreign_key "prepaid_codes", "prepaid_types"
  add_foreign_key "prepaid_purchases", "prepaid_codes"
  add_foreign_key "prepaid_purchases", "users"
  add_foreign_key "reload_requests", "admins"
  add_foreign_key "reload_requests", "users"
  add_foreign_key "user_logs", "users"
end
