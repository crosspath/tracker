# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class ChangeColumnsInPayouts < ActiveRecord::Migration[8.0]
  def up
    change_column "finance_payouts", "money", :decimal, precision: 8, scale: 2
    add_column "finance_payouts",
      "rate",
      :decimal,
      precision: 5,
      null: false,
      default: 0,
      comment: "Hour rate"
  end

  def down
    change_column "finance_payouts", "money", :decimal, precision: 6
    remove_column "finance_payouts", "rate"
  end
end
# rubocop:enable Rails/BulkChangeTable
