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

ActiveRecord::Schema.define(version: 20170410140226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adminusers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "adminusers", ["org_id"], name: "index_adminusers_on_org_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "title"
    t.text     "message_text"
    t.date     "create_date"
    t.integer  "org_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "text_message"
  end

  add_index "messages", ["org_id"], name: "index_messages_on_org_id", using: :btree

  create_table "messhistories", force: :cascade do |t|
    t.date     "sent_date"
    t.integer  "message_id"
    t.integer  "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messhistories", ["message_id"], name: "index_messhistories_on_message_id", using: :btree
  add_index "messhistories", ["org_id"], name: "index_messhistories_on_org_id", using: :btree

  create_table "orgs", force: :cascade do |t|
    t.string   "org_name"
    t.string   "org_status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "hot_message"
    t.text     "hot_text_message"
  end

  create_table "reps", force: :cascade do |t|
    t.string   "first_name"
    t.string   "first_three"
    t.string   "last_name"
    t.string   "url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "reps", ["first_three", "last_name"], name: "unique_rep_index", unique: true, using: :btree

  create_table "targetmessages", force: :cascade do |t|
    t.date     "sent_date"
    t.text     "message_text"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "target_id"
  end

  add_index "targetmessages", ["target_id"], name: "index_targetmessages_on_target_id", using: :btree
  add_index "targetmessages", ["user_id"], name: "index_targetmessages_on_user_id", using: :btree

  create_table "targets", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "zip"
    t.string   "plus4"
    t.string   "salutation"
    t.string   "email"
    t.string   "phone"
    t.boolean  "unsubscribed"
    t.date     "unsubscribed_date"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "status"
    t.string   "slug"
    t.integer  "contact_method"
  end

  add_index "targets", ["slug"], name: "index_targets_on_slug", unique: true, using: :btree
  add_index "targets", ["user_id"], name: "index_targets_on_user_id", using: :btree

  create_table "user_orgs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_orgs", ["org_id"], name: "index_user_orgs_on_org_id", using: :btree
  add_index "user_orgs", ["user_id"], name: "index_user_orgs_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "enrollment"
    t.date     "inactivation"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "admin"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "adminusers", "orgs"
  add_foreign_key "messages", "orgs"
  add_foreign_key "messhistories", "messages"
  add_foreign_key "messhistories", "orgs"
  add_foreign_key "user_orgs", "orgs"
end
