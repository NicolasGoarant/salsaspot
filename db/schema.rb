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

ActiveRecord::Schema[7.2].define(version: 2026_01_30_140149) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "slug"
    t.string "event_type"
    t.string "dance_styles", default: [], array: true
    t.string "level"
    t.string "venue_name"
    t.string "address"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "recurrence"
    t.integer "day_of_week"
    t.decimal "price", precision: 8, scale: 2
    t.boolean "is_free", default: false
    t.boolean "has_lessons", default: false
    t.string "lessons_time"
    t.string "organizer_name"
    t.string "organizer_email"
    t.string "phone"
    t.string "website"
    t.string "facebook_url"
    t.string "ticket_url"
    t.boolean "is_active", default: true
    t.boolean "is_verified", default: false
    t.integer "views_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_events_on_city"
    t.index ["dance_styles"], name: "index_events_on_dance_styles", using: :gin
    t.index ["is_active"], name: "index_events_on_is_active"
    t.index ["latitude", "longitude"], name: "index_events_on_latitude_and_longitude"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["starts_at"], name: "index_events_on_starts_at"
  end
end
