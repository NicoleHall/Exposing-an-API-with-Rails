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

ActiveRecord::Schema.define(version: 20151229203401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "presents", force: :cascade do |t|
    t.string   "name"
    t.decimal  "price"
    t.boolean  "regifted"
    t.integer  "receiver"
    t.integer  "giver"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "present_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["present_id"], name: "index_users_on_present_id", using: :btree

  create_table "wrappings", force: :cascade do |t|
    t.string   "name"
    t.integer  "present_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "wrappings", ["present_id"], name: "index_wrappings_on_present_id", using: :btree

  add_foreign_key "users", "presents"
  add_foreign_key "wrappings", "presents"
end
