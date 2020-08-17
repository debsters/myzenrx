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

ActiveRecord::Schema.define(version: 20200728213022) do

  create_table "entries", force: :cascade do |t|
    t.datetime "date_time"
    t.string   "med_time"
    t.string   "dose_form"
    t.string   "dose_strength"
    t.integer  "dose_interval"
    t.integer  "mood"
    t.integer  "energy_level"
    t.string   "food_ate"
    t.string   "med_take_effect"
    t.string   "med_took_effect"
    t.string   "med_stopped_time"
    t.string   "med_lasted"
    t.string   "content"
    t.integer  "user_id"
    t.integer  "user_medication_id"
  end

  create_table "indices", force: :cascade do |t|
    t.string "letter"
  end

  create_table "medications", force: :cascade do |t|
    t.string  "source"
    t.string  "name"
    t.string  "description"
    t.string  "side_effects"
    t.string  "url"
    t.string  "side_effects_url"
    t.integer "index_id"
  end

  create_table "user_medications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "medication_id"
    t.integer "currently_taking"
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "username"
    t.string "email"
    t.string "password_digest"
  end

end
