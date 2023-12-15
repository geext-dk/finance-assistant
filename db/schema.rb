# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_12_09_203437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "currency", null: false
    t.uuid "user_id", null: false
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "merchants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "country", null: false
    t.uuid "user_id", null: false
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_merchants_on_user_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country", null: false
    t.string "name", null: false
    t.integer "quantity_type", null: false
    t.uuid "user_id", null: false
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "transaction_line_items", primary_key: ["owner_transaction_id", "product_id"], force: :cascade do |t|
    t.uuid "product_id", null: false
    t.uuid "owner_transaction_id", null: false
    t.integer "quantity_pieces"
    t.float "quantity_weighted"
    t.integer "price_cents", null: false
    t.integer "discounted_price_cents"
    t.integer "total_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_transaction_id"], name: "index_transaction_line_items_on_owner_transaction_id"
    t.index ["product_id"], name: "index_transaction_line_items_on_product_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country", null: false
    t.string "currency", null: false
    t.uuid "merchant_id", null: false
    t.uuid "account_id", null: false
    t.uuid "user_id", null: false
    t.datetime "date", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "unique_emails", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "merchants", "users"
  add_foreign_key "products", "users"
  add_foreign_key "transaction_line_items", "products"
  add_foreign_key "transaction_line_items", "transactions", column: "owner_transaction_id"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "merchants"
  add_foreign_key "transactions", "users"
end
