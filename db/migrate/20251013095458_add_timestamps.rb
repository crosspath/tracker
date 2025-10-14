# frozen_string_literal: true

class AddTimestamps < ActiveRecord::Migration[8.0]
  def change
    add_timestamps "finance_payouts", default: -> { "CURRENT_TIMESTAMP" }
  end
end
