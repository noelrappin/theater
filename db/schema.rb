# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160531114033) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "discount_codes", force: :cascade do |t|
    t.string   "code"
    t.integer  "percentage"
    t.text     "description"
    t.integer  "min_amount_cents"
    t.integer  "max_discount_cents"
    t.integer  "max_uses"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "image_url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "payment_line_items", force: :cascade do |t|
    t.integer  "payment_id"
    t.integer  "reference_id"
    t.integer  "price_cents"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "reference_type"
    t.integer  "original_line_item_id"
    t.integer  "administrator_id"
    t.integer  "refund_status",         default: 0
  end

  add_index "payment_line_items", ["administrator_id"], name: "index_payment_line_items_on_administrator_id", using: :btree
  add_index "payment_line_items", ["original_line_item_id"], name: "index_payment_line_items_on_original_line_item_id", using: :btree
  add_index "payment_line_items", ["payment_id"], name: "index_payment_line_items_on_payment_id", using: :btree
  add_index "payment_line_items", ["reference_id"], name: "index_payment_line_items_on_reference_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "price_cents"
    t.integer  "status"
    t.string   "reference"
    t.string   "payment_method"
    t.string   "response_id"
    t.json     "full_response"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "original_payment_id"
    t.integer  "administrator_id"
    t.integer  "discount_code_id"
    t.integer  "discount_cents"
  end

  add_index "payments", ["administrator_id"], name: "index_payments_on_administrator_id", using: :btree
  add_index "payments", ["original_payment_id"], name: "index_payments_on_original_payment_id", using: :btree
  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "performances", force: :cascade do |t|
    t.integer  "event_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "performances", ["event_id"], name: "index_performances_on_event_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string  "remote_id"
    t.string  "plan_name",                   null: false
    t.integer "price_cents",                 null: false
    t.string  "interval",                    null: false
    t.integer "tickets_allowed",             null: false
    t.string  "ticket_category",             null: false
    t.integer "status",          default: 0
    t.string  "description"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "status"
    t.string   "payment_method"
    t.string   "remote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "performance_id"
    t.integer  "status"
    t.integer  "access"
    t.integer  "price_cents"
    t.string   "reference"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "payment_reference"
  end

  add_index "tickets", ["performance_id"], name: "index_tickets_on_performance_id", using: :btree
  add_index "tickets", ["user_id"], name: "index_tickets_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.integer  "role"
    t.string   "stripe_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "payment_line_items", "payments"
  add_foreign_key "payment_line_items", "tickets", column: "reference_id"
  add_foreign_key "payments", "users"
  add_foreign_key "performances", "events"
  add_foreign_key "tickets", "performances"
  add_foreign_key "tickets", "users"
end
