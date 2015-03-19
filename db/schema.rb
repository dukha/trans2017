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

ActiveRecord::Schema.define(version: 20150320245450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calmapp_developers", force: :cascade do |t|
    t.integer "calmapp_id"
    t.integer "user_id"
  end

  create_table "calmapp_versions", force: :cascade do |t|
    t.integer  "calmapp_id",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
    t.string   "copied_from_version"
  end

  add_index "calmapp_versions", ["calmapp_id"], name: "i_calmapp_versions_appliction_id", using: :btree

  create_table "calmapp_versions_translation_languages", force: :cascade do |t|
    t.integer  "calmapp_version_id",      null: false
    t.integer  "translation_language_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calmapp_versions_translation_languages", ["calmapp_version_id", "translation_language_id"], name: "iu_calmapp_versions_languages_calmapp_id_lanugage_id", unique: true, using: :btree

  create_table "calmapps", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calmapps", ["name"], name: "iu_calmapps_name", unique: true, using: :btree

  create_table "cavs_tl_translators", force: :cascade do |t|
    t.integer  "cavs_translation_language_id", null: false
    t.integer  "translator_id",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "dot_key_code_translation_editors", force: :cascade do |t|
    t.string   "dot_key_code"
    t.string   "editor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: :cascade do |t|
    t.string   "iso_code",   null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["iso_code"], name: "iu_languages_iso_code", unique: true, using: :btree
  add_index "languages", ["name"], name: "iu_languages_name", unique: true, using: :btree

  create_table "profiles", force: :cascade do |t|
    t.text     "rools"
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redis_databases", force: :cascade do |t|
    t.integer  "redis_instance_id"
    t.integer  "redis_db_index",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "release_status_id"
    t.integer  "calmapp_version_id"
  end

  add_index "redis_databases", ["calmapp_version_id"], name: "index_redis_databases_on_calmapp_version_id", using: :btree
  add_index "redis_databases", ["release_status_id"], name: "index_redis_databases_on_release_status_id", using: :btree

  create_table "redis_instances", force: :cascade do |t|
    t.string  "host",          null: false
    t.integer "port",          null: false
    t.string  "password",      null: false
    t.integer "max_databases"
    t.string  "description"
  end

  add_index "redis_instances", ["host", "port"], name: "iu_redis_instances_host_port", unique: true, using: :btree

  create_table "release_statuses", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "special_partial_dot_keys", force: :cascade do |t|
    t.string   "partial_dot_key"
    t.string   "sort"
    t.boolean  "cldr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "special_partial_dot_keys", ["partial_dot_key"], name: "index_special_partial_dot_keys_on_partial_dot_key", using: :btree

  create_table "translation_editor_params", force: :cascade do |t|
    t.integer  "translation_editor_id"
    t.string   "param_name"
    t.string   "param_sequence"
    t.string   "param_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translation_hints", force: :cascade do |t|
    t.string   "dot_key_code", null: false
    t.string   "heading"
    t.string   "example"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translation_languages", force: :cascade do |t|
    t.string   "iso_code",                          null: false
    t.string   "name",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plural_sort", default: "one_other", null: false
  end

  add_index "translation_languages", ["iso_code"], name: "iu_tlanguages_iso_code", unique: true, using: :btree
  add_index "translation_languages", ["name"], name: "iu_tlanguages_name", unique: true, using: :btree

  create_table "translations", force: :cascade do |t|
    t.string   "dot_key_code",                 null: false
    t.text     "translation"
    t.integer  "translations_upload_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cavs_translation_language_id"
  end

  add_index "translations", ["cavs_translation_language_id", "dot_key_code"], name: "iu_translations_language_dot_key_code", unique: true, using: :btree
  add_index "translations", ["cavs_translation_language_id"], name: "i_translations_language", using: :btree
  add_index "translations", ["dot_key_code"], name: "i_translations_dot_key_code", using: :btree

  create_table "translations_uploads", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cavs_translation_language_id"
    t.string   "yaml_upload"
    t.boolean  "written_to_db"
  end

  add_index "translations_uploads", ["cavs_translation_language_id"], name: "index_translations_uploads_on_cavs_translation_language_id", using: :btree

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "profile_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_profiles", ["profile_id"], name: "index_user_profiles_on_profile_id", using: :btree
  add_index "user_profiles", ["user_id", "profile_id"], name: "index_user_profiles_on_user_id_and_profile_id", unique: true, using: :btree
  add_index "user_profiles", ["user_id"], name: "index_user_profiles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "actual_name",                            null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.boolean  "translator",             default: false
    t.boolean  "developer",              default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "whiteboard_types", force: :cascade do |t|
    t.string   "name_english"
    t.string   "translation_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "whiteboards", force: :cascade do |t|
    t.text     "info",               null: false
    t.integer  "whiteboard_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "whiteboards", ["whiteboard_type_id"], name: "iu_whiteboards_whiteboard_type", unique: true, using: :btree

  add_foreign_key "calmapp_versions", "calmapps", name: "fk_calmapp_versions_calmapps", on_delete: :restrict
  add_foreign_key "redis_databases", "redis_instances", name: "fk_redis_databases_redis_instances", on_delete: :restrict
  add_foreign_key "whiteboards", "whiteboard_types", name: "fk_whiteboards_whiteboard_types", on_delete: :cascade
end
