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

ActiveRecord::Schema[7.0].define(version: 2025_08_08_161941) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "consultation_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "consultation_id", null: false
    t.text "diagnosis"
    t.text "procedures"
    t.text "prescription"
    t.text "doctor_notes"
    t.boolean "follow_up_needed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_consultation_reports_on_consultation_id", unique: true
  end

  create_table "consultation_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "color", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "consultations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "appointment", null: false
    t.integer "status", default: 0
    t.integer "appointment_type", default: 0
    t.boolean "is_archived", default: false
    t.uuid "doctor_id", null: false
    t.uuid "patient_id", null: false
    t.string "refus_reason"
    t.string "note"
    t.string "room_code"
    t.integer "order", default: 1
    t.boolean "is_payed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "date(appointment), doctor_id, patient_id", name: "index_consultations_on_date_and_doctor_and_patient", unique: true
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.uuid "doctor_id", null: false
    t.boolean "is_archived", default: false
    t.integer "order", default: 1
    t.date "remind_date"
    t.datetime "notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "noticed_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.uuid "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.uuid "event_id", null: false
    t.string "recipient_type", null: false
    t.uuid "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "firstname"
    t.string "lastname"
    t.string "address"
    t.date "birthday"
    t.integer "gender", default: 0
    t.integer "civil_status", default: 0
    t.boolean "is_archived", default: false
    t.integer "order", default: 1
    t.string "type"
    t.string "location"
    t.string "code_user"
    t.string "phone_number"
    t.string "medical_history"
    t.integer "plan", default: 0
    t.boolean "is_emailable", default: false
    t.boolean "is_notifiable", default: false
    t.boolean "is_smsable", default: false
    t.boolean "working_saturday", default: false
    t.integer "plateform"
    t.string "time_zone"
    t.uuid "doctor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language", default: "fr"
    t.string "confirmation_code"
    t.datetime "confirmation_code_generated_at"
    t.string "jti", default: "", null: false
    t.boolean "is_verified", default: false
    t.boolean "has_access_acount", default: true
    t.boolean "has_access_agenda", default: true
    t.boolean "has_access_patients", default: true
    t.boolean "has_access_hr_module", default: false
    t.boolean "has_access_intelligent_prescrip", default: false
    t.boolean "has_access_manage_notifications", default: false
    t.boolean "has_access_manage_documents", default: false
    t.boolean "has_access_multilang_platform", default: false
    t.datetime "acount_access_granted_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "consultations", "users", column: "doctor_id"
  add_foreign_key "consultations", "users", column: "patient_id"
  add_foreign_key "documents", "users", column: "doctor_id"
end
