# frozen_string_literal: true

class ChangePayouts < ActiveRecord::Migration[8.0]
  COLUMNS = {
    "payout" => {foreign_key: {to_table: "finance_payouts"}, null: true, comment: "Payout"},
    "rate" => {precision: 5, null: false, comment: "Hour rate", default: 0},
  }.freeze

  def change
    remove_column "work_logs", "rate", :decimal, **COLUMNS["rate"]
    add_reference "work_logs", "payout", **COLUMNS["payout"]

    change_column_null "finance_payouts", "money", true
    change_column_comment "finance_payouts", "created_at", from: nil, to: "Created at"
  end
end
