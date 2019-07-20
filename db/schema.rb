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

ActiveRecord::Schema.define(version: 2019_07_18_072248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "languages", force: :cascade do |t|
    t.text "code"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "translations", force: :cascade do |t|
    t.text "word_pt"
    t.text "genre_pt"
    t.bigint "unidade_id"
    t.text "transl_eng"
    t.text "transl_ger"
    t.text "transl_spa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unidade_id"], name: "index_translations_on_unidade_id"
  end

  create_table "unidades", force: :cascade do |t|
    t.text "title"
    t.text "book"
    t.text "nr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_translations", force: :cascade do |t|
    t.bigint "language_id"
    t.bigint "translation_id"
    t.bigint "unidade_id"
    t.text "word_pt"
    t.text "genre_pt"
    t.text "main_transl"
    t.text "alt_transl_1"
    t.text "alt_transl_2"
    t.text "alt_transl_3"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_user_translations_on_language_id"
    t.index ["translation_id"], name: "index_user_translations_on_translation_id"
    t.index ["unidade_id"], name: "index_user_translations_on_unidade_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "translations", "unidades"
  add_foreign_key "user_translations", "languages"
  add_foreign_key "user_translations", "translations"
  add_foreign_key "user_translations", "unidades"
end
