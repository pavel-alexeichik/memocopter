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

ActiveRecord::Schema.define(version: 20160904095059) do

  create_table "cards", force: :cascade do |t|
    t.string   "question",                     null: false
    t.string   "answer",                       null: false
    t.integer  "cards_set_id",                 null: false
    t.boolean  "is_public",    default: false
    t.integer  "order",        default: 0
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["cards_set_id"], name: "index_cards_on_cards_set_id"
  end

  create_table "cards_sets", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cards_sets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean  "admin"
    t.datetime "last_seen"
    t.string   "email"
    t.string   "display_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end