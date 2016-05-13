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

ActiveRecord::Schema.define(version: 20160427195701) do

  create_table "addons_orderables", force: :cascade do |t|
    t.integer  "milktea_orderable_id", null: false
    t.integer  "milktea_addon_id",     null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "addons_orderables", ["milktea_addon_id"], name: "index_addons_orderables_on_milktea_addon_id"
  add_index "addons_orderables", ["milktea_orderable_id"], name: "index_addons_orderables_on_milktea_orderable_id"

  create_table "admins", force: :cascade do |t|
    t.boolean  "super_admin", default: false, null: false
    t.boolean  "accountant",  default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "dish_categories", force: :cascade do |t|
    t.string   "name",                       null: false
    t.boolean  "active",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "drivers", force: :cascade do |t|
    t.string   "nickname",      default: "Steve DBD", null: false
    t.string   "vehicle_make"
    t.string   "vehicle_model"
    t.string   "vehicle_color"
    t.string   "license_plate"
    t.boolean  "active",        default: false,       null: false
    t.decimal  "lat"
    t.decimal  "long"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string   "title",                      null: false
    t.string   "message",                    null: false
    t.string   "email"
    t.boolean  "read",       default: false
    t.boolean  "responded",  default: false
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id"

  create_table "locations_times", force: :cascade do |t|
    t.integer  "day_of_week",        null: false
    t.integer  "pickup_time_id",     null: false
    t.integer  "pickup_location_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "locations_times", ["day_of_week"], name: "index_locations_times_on_day_of_week"
  add_index "locations_times", ["pickup_location_id"], name: "index_locations_times_on_pickup_location_id"
  add_index "locations_times", ["pickup_time_id"], name: "index_locations_times_on_pickup_time_id"

  create_table "milktea_addons", force: :cascade do |t|
    t.string   "name",                       null: false
    t.decimal  "price",                      null: false
    t.boolean  "active",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "milktea_orderables", force: :cascade do |t|
    t.integer  "sweet_scale",  null: false
    t.integer  "temp_scale",   null: false
    t.integer  "size",         null: false
    t.integer  "milktea_id",   null: false
    t.integer  "orderable_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "milktea_orderables", ["milktea_id"], name: "index_milktea_orderables_on_milktea_id"
  add_index "milktea_orderables", ["orderable_id"], name: "index_milktea_orderables_on_orderable_id"

  create_table "orderables", force: :cascade do |t|
    t.integer  "buyable_id"
    t.string   "buyable_type"
    t.integer  "ownable_id"
    t.string   "ownable_type"
    t.decimal  "unit_price",               null: false
    t.integer  "quantity",     default: 1, null: false
    t.integer  "status",       default: 0, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "orderables", ["buyable_type", "buyable_id"], name: "index_orderables_on_buyable_type_and_buyable_id"
  add_index "orderables", ["ownable_type", "ownable_id"], name: "index_orderables_on_ownable_type_and_ownable_id"

  create_table "orders", force: :cascade do |t|
    t.decimal  "total",                            null: false
    t.integer  "payment_status",       default: 0
    t.integer  "payment_method",                   null: false
    t.string   "payment_id"
    t.string   "refund_id"
    t.integer  "fulfillment_status",   default: 0
    t.integer  "issue_status",         default: 0
    t.integer  "satisfaction",         default: 0
    t.string   "issue"
    t.string   "solution"
    t.string   "note"
    t.string   "recipient_name",                   null: false
    t.string   "recipient_phone",                  null: false
    t.string   "recipient_wechat"
    t.string   "delivery_location",                null: false
    t.string   "delivery_instruction"
    t.datetime "delivery_time",                    null: false
    t.integer  "shopper_id",                       null: false
    t.integer  "driver_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "orders", ["driver_id"], name: "index_orders_on_driver_id"
  add_index "orders", ["shopper_id"], name: "index_orders_on_shopper_id"

  create_table "pickup_locations", force: :cascade do |t|
    t.string   "name",                        null: false
    t.string   "address",                     null: false
    t.string   "description"
    t.boolean  "active",      default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "pickup_times", force: :cascade do |t|
    t.integer  "pickup_hour",   null: false
    t.integer  "pickup_minute", null: false
    t.integer  "cutoff_hour",   null: false
    t.integer  "cutoff_minute", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "providers", force: :cascade do |t|
    t.boolean  "chief_liaison", default: false, null: false
    t.integer  "store_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "providers", ["store_id"], name: "index_providers_on_store_id"

  create_table "recipes", force: :cascade do |t|
    t.string   "name",                             null: false
    t.string   "description",                      null: false
    t.string   "image"
    t.decimal  "price",                            null: false
    t.string   "type",                             null: false
    t.boolean  "active",           default: false
    t.integer  "dish_category_id"
    t.integer  "store_id",                         null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "recipes", ["dish_category_id"], name: "index_recipes_on_dish_category_id"
  add_index "recipes", ["store_id"], name: "index_recipes_on_store_id"

  create_table "shoppers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stores", force: :cascade do |t|
    t.string   "name",                       null: false
    t.string   "phone",                      null: false
    t.string   "owner",                      null: false
    t.string   "email"
    t.string   "website"
    t.string   "address",                    null: false
    t.decimal  "lat",                        null: false
    t.decimal  "long",                       null: false
    t.boolean  "active",     default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "email",                             null: false
    t.string   "phone"
    t.string   "wechat"
    t.string   "password_digest",                   null: false
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "role_id"
    t.string   "role_type"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["role_type", "role_id"], name: "index_users_on_role_type_and_role_id"

end
