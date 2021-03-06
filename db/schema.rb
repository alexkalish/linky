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

ActiveRecord::Schema.define(version: 2019_02_14_135659) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "link_redirects", id: false, force: :cascade do |t|
    t.integer "link_id", null: false
    t.datetime "occurred_at", null: false
    t.text "referrer_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "links", force: :cascade do |t|
    t.bigint "user_id"
    t.string "destination_url", null: false
    t.string "public_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_identifier"], name: "index_links_on_public_identifier", unique: true
    t.index ["user_id", "destination_url"], name: "index_links_on_user_id_and_destination_url", unique: true
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "link_redirects", "links", name: "link_redirects_link_id_fkey"
end
