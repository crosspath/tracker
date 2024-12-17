# frozen_string_literal: true

class CreateCoreTables < ActiveRecord::Migration[8.0]
  def change
    create_table "goals_projects" do |t|
      t.string "title", null: false, comment: "Title"
      t.string "description", null: false, default: "", comment: "Description"
    end

    create_table "goals_requirements" do |t|
      # enum: "feature", "user_story", "task"
      t.string "kind", null: false, comment: "Type of requirement"
      t.references "project",
        null: false,
        foreign_key: {to_table: "goals_projects"},
        comment: "Project"
      t.integer "position", null: false
      t.string "title", null: false, comment: "Title"
      t.string "description", null: false, default: "", comment: "Description"
      t.jsonb "optional_data", null: false, default: {}, comment: "Optional data"
    end

    create_table "goals_requirement_relations" do |t|
      t.references "left",
        null: false,
        foreign_key: {to_table: "goals_requirements"},
        comment: "Required for"
      t.references "right",
        null: false,
        foreign_key: {to_table: "goals_requirements"},
        comment: "Depends on"
      t.string "kind", null: false, comment: "Type of relation" # enum: "starts_after", "includes"
    end

    create_table "work_workers" do |t|
      t.integer "position", null: false
      t.string "title", null: false, comment: "Title"
      t.decimal "rate", null: false, precision: 5, comment: "Hour rate"
      t.string "payment_info", null: false, default: "", comment: "Payment info"
    end

    create_table "work_logs" do |t|
      t.references "worker", null: false, foreign_key: {to_table: "work_workers"}, comment: "Worker"
      t.references "requirement",
        null: false,
        foreign_key: {to_table: "goals_requirements"},
        comment: "Requirement"
      t.date "started_at", comment: "Started at"
      t.date "ended_at", comment: "Ended at"
      t.decimal "planned_duration",
        null: false,
        precision: 4,
        scale: 2,
        comment: "Planned duration in hours"
      t.decimal "rate", null: false, precision: 5, comment: "Hour rate"
    end

    create_table "work_reviews" do |t|
      t.references "worker", null: false, foreign_key: {to_table: "work_workers"}, comment: "Worker"
      t.references "requirement",
        null: false,
        foreign_key: {to_table: "goals_requirements"},
        comment: "Requirement"
      t.date "performed_at", null: false, comment: "Performed at"
      t.decimal "calculated_duration",
        null: false,
        precision: 4,
        scale: 2,
        comment: "Calculated duration in hours"
      t.decimal "rate", null: false, precision: 5, comment: "Hour rate"
    end

    create_table "finance_payouts" do |t|
      t.references "worker", null: false, foreign_key: {to_table: "work_workers"}, comment: "Worker"
      t.decimal "money", null: false, precision: 6, comment: "Amount of money"
      t.date "paid_at", comment: "Paid at"
    end
  end
end
