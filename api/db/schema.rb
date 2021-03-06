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

ActiveRecord::Schema.define(version: 20161122143654) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "cash"
  end

  create_table "holdings", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "stock_id"
    t.float    "purchase_price"
    t.float    "sale_price"
    t.datetime "held_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "quantity"
    t.index ["agent_id"], name: "index_holdings_on_agent_id", using: :btree
    t.index ["held_at"], name: "index_holdings_on_held_at", using: :btree
    t.index ["stock_id"], name: "index_holdings_on_stock_id", using: :btree
  end

  create_table "stock_values", force: :cascade do |t|
    t.integer  "stock_id"
    t.float    "value"
    t.datetime "quoted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quoted_at"], name: "index_stock_values_on_quoted_at", using: :btree
    t.index ["stock_id"], name: "index_stock_values_on_stock_id", using: :btree
  end

  create_table "stocks", force: :cascade do |t|
    t.string   "symbol"
    t.integer  "row"
    t.integer  "column"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
