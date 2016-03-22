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

ActiveRecord::Schema.define(version: 20160321215013) do

  create_table "addons_orderables", force: :cascade do |t|
    t.integer  "milktea_orderable_id"
    t.integer  "milktea_addon_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "addons_orderables", ["milktea_addon_id"], name: "index_addons_orderables_on_milktea_addon_id"
  add_index "addons_orderables", ["milktea_orderable_id"], name: "index_addons_orderables_on_milktea_orderable_id"

  create_table "dish_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "image"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "milktea_addons", force: :cascade do |t|
    t.string   "name"
    t.decimal  "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "milktea_orderables", force: :cascade do |t|
    t.integer  "sweet_scale"
    t.integer  "temp_scale"
    t.integer  "size"
    t.integer  "milktea_id"
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
    t.decimal  "unit_price"
    t.integer  "quantity",     default: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "orderables", ["buyable_type", "buyable_id"], name: "index_orderables_on_buyable_type_and_buyable_id"
  add_index "orderables", ["ownable_type", "ownable_id"], name: "index_orderables_on_ownable_type_and_ownable_id"

  create_table "orders", force: :cascade do |t|
    t.decimal  "total"
    t.integer  "payment_method"
    t.boolean  "paid",           default: false
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "recipes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "image"
    t.decimal  "price"
    t.string   "type"
    t.integer  "dish_category_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "recipes", ["dish_category_id"], name: "index_recipes_on_dish_category_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
