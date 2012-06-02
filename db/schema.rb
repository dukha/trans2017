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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201204041046086) do

  create_table "languages", :force => true do |t|
    t.string   "iso_code",   :null => false
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["iso_code"], :name => "iu_languages_iso_code", :unique => true
  add_index "languages", ["name"], :name => "iu_languages_name", :unique => true

  create_table "locations", :force => true do |t|
    t.string   "name",             :null => false
    t.string   "type",             :null => false
    t.integer  "parent_id"
    t.string   "translation_code"
    t.string   "fqdn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organisation_id", :null => false
    t.integer  "profile_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.text     "roles"
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",                               :null => false
    t.string   "actual_name",                            :null => false
    t.integer  "current_permission_id"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "whiteboard_types", :force => true do |t|
    t.string   "name_english"
    t.string   "translation_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "whiteboards", :force => true do |t|
    t.text     "info",               :null => false
    t.integer  "whiteboard_type_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "whiteboards", ["whiteboard_type_id"], :name => "iu_whiteboards_whiteboard_type", :unique => true

end
