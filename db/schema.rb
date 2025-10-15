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

ActiveRecord::Schema[8.0].define(version: 2025_10_15_201201) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "finance_payouts", force: :cascade do |t|
    t.bigint "worker_id", null: false, comment: "Worker"
    t.decimal "money", precision: 8, scale: 2, comment: "Amount of money"
    t.date "paid_at", comment: "Paid at"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Created at"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.decimal "rate", precision: 5, default: "0", null: false, comment: "Hour rate"
    t.index ["worker_id"], name: "index_finance_payouts_on_worker_id"
  end

  create_table "goals_projects", force: :cascade do |t|
    t.string "title", null: false, comment: "Title"
    t.string "description", default: "", null: false, comment: "Description"
  end

  create_table "goals_requirement_relations", force: :cascade do |t|
    t.bigint "left_id", null: false, comment: "Required for"
    t.bigint "right_id", null: false, comment: "Depends on"
    t.string "kind", null: false, comment: "Type of relation"
    t.index ["left_id"], name: "index_goals_requirement_relations_on_left_id"
    t.index ["right_id"], name: "index_goals_requirement_relations_on_right_id"
  end

  create_table "goals_requirements", force: :cascade do |t|
    t.string "kind", null: false, comment: "Type of requirement"
    t.bigint "project_id", null: false, comment: "Project"
    t.integer "position", null: false
    t.string "title", null: false, comment: "Title"
    t.string "description", default: "", null: false, comment: "Description"
    t.jsonb "optional_data", default: {}, null: false, comment: "Optional data"
    t.index ["project_id"], name: "index_goals_requirements_on_project_id"
  end

  create_table "work_logs", force: :cascade do |t|
    t.bigint "worker_id", null: false, comment: "Worker"
    t.bigint "requirement_id", null: false, comment: "Requirement"
    t.date "started_at", comment: "Started at"
    t.date "ended_at", comment: "Ended at"
    t.decimal "planned_duration", precision: 5, scale: 3, null: false, comment: "Planned duration in hours"
    t.bigint "payout_id", comment: "Payout"
    t.string "kind", null: false, comment: "Type of work log"
    t.index ["payout_id"], name: "index_work_logs_on_payout_id"
    t.index ["requirement_id"], name: "index_work_logs_on_requirement_id"
    t.index ["worker_id"], name: "index_work_logs_on_worker_id"
  end

  create_table "work_workers", force: :cascade do |t|
    t.integer "position", null: false
    t.string "title", null: false, comment: "Title"
    t.decimal "rate", precision: 5, null: false, comment: "Hour rate"
    t.string "payment_info", default: "", null: false, comment: "Payment info"
  end

  add_foreign_key "finance_payouts", "work_workers", column: "worker_id"
  add_foreign_key "goals_requirement_relations", "goals_requirements", column: "left_id"
  add_foreign_key "goals_requirement_relations", "goals_requirements", column: "right_id"
  add_foreign_key "goals_requirements", "goals_projects", column: "project_id"
  add_foreign_key "work_logs", "finance_payouts", column: "payout_id"
  add_foreign_key "work_logs", "goals_requirements", column: "requirement_id"
  add_foreign_key "work_logs", "work_workers", column: "worker_id"
end
