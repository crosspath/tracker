# frozen_string_literal: true

class ChangeColumnsInWorkLogs < ActiveRecord::Migration[8.0]
  def up
    change_column "work_logs", "planned_duration", :decimal, precision: 5, scale: 3
  end

  def down
    change_column "work_logs", "planned_duration", :decimal, precision: 4, scale: 2
  end
end
