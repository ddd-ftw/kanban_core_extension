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

ActiveRecord::Schema.define(version: 20150908023413) do

  create_table "backlogged_feature_records", force: :cascade do |t|
    t.integer  "feature_record_id", null: false
    t.datetime "backlogged_at",     null: false
  end

  create_table "board_records", force: :cascade do |t|
    t.string "project_id_str", null: false
  end

  add_index "board_records", ["project_id_str"], name: "index_board_records_on_project_id_str"

  create_table "card_records", force: :cascade do |t|
    t.integer "board_record_id",     null: false
    t.string  "feature_id_str",      null: false
    t.string  "progress_phase_name", null: false
    t.string  "progress_state_name"
  end

  create_table "feature_records", force: :cascade do |t|
    t.string "project_id_str",      null: false
    t.string "feature_id_str",      null: false
    t.string "description_summary", null: false
    t.text   "description_detail"
  end

  create_table "phase_spec_records", force: :cascade do |t|
    t.integer "project_record_id", null: false
    t.integer "order",             null: false
    t.string  "phase_name",        null: false
    t.integer "wip_limit_count"
  end

  add_index "phase_spec_records", ["project_record_id", "order"], name: "index_phase_spec_records_on_project_record_id_and_order"

  create_table "project_records", force: :cascade do |t|
    t.string "project_id_str",   null: false
    t.string "description_name", null: false
    t.text   "description_goal", null: false
  end

  add_index "project_records", ["project_id_str"], name: "index_project_records_on_project_id_str"

  create_table "shipped_feature_records", force: :cascade do |t|
    t.integer  "feature_record_id", null: false
    t.datetime "shipped_at",        null: false
  end

  create_table "state_records", force: :cascade do |t|
    t.integer "project_record_id", null: false
    t.string  "phase_name",        null: false
    t.integer "order",             null: false
    t.string  "state_name",        null: false
  end

  add_index "state_records", ["project_record_id", "phase_name", "order"], name: "project_phase_order"

end
