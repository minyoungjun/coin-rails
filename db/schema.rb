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

ActiveRecord::Schema.define(version: 20171225214327) do

  create_table "candledata", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "candlesize_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.float "open", limit: 24
    t.float "high", limit: 24
    t.float "low", limit: 24
    t.float "close", limit: 24
    t.float "vol_btc", limit: 24
    t.float "vol_currency", limit: 24
    t.float "weighted", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candlesize_id"], name: "index_candledata_on_candlesize_id"
    t.index ["end_time"], name: "index_candledata_on_end_time"
    t.index ["start_time"], name: "index_candledata_on_start_time"
  end

  create_table "candlesizes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "minute"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "minutes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "time"
    t.float "open", limit: 24
    t.float "high", limit: 24
    t.float "low", limit: 24
    t.float "close", limit: 24
    t.float "vol_btc", limit: 24
    t.float "vol_currency", limit: 24
    t.float "weighted", limit: 24
    t.index ["time"], name: "index_minutes_on_time", unique: true
  end

  create_table "movings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "candlesize_id"
    t.integer "candledatum_id"
    t.integer "size"
    t.datetime "start_time"
    t.float "average", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candlesize_id"], name: "index_movings_on_candlesize_id"
    t.index ["size"], name: "index_movings_on_size"
    t.index ["start_time"], name: "index_movings_on_start_time"
  end

end
