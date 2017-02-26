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

ActiveRecord::Schema.define(version: 20170224200714) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "messages", force: :cascade do |t|
    t.string   "title"
    t.text     "message_text"
    t.date     "create_date"
    t.integer  "org_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "messages", ["org_id"], name: "index_messages_on_org_id", using: :btree

  create_table "orgs", force: :cascade do |t|
    t.string   "org_name"
    t.string   "org_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "targets", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.integer  "zip"
    t.integer  "plus4"
    t.string   "salutation"
    t.string   "email"
    t.boolean  "rec_email"
    t.boolean  "rec_text"
    t.string   "phone"
    t.boolean  "unsubscribed"
    t.date     "unsubscribed_date"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "targets", ["user_id"], name: "index_targets_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.date     "enrollment"
    t.date     "inactivation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_foreign_key "messages", "orgs"
  add_foreign_key "targets", "users"
end
