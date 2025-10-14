# frozen_string_literal: true

class MergeWorkLogsAndReviews < ActiveRecord::Migration[8.0]
  def change
    drop_table "work_reviews" do |t|
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

    add_column "work_logs",
      "kind",
      :string,
      null: false,
      comment: "Type of work log",
      default: AppConfig.work_logs.members.first
  end
end
