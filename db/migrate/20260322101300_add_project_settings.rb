# frozen_string_literal: true

class AddProjectSettings < ActiveRecord::Migration[8.0]
  def change
    add_column "goals_projects", "settings", :jsonb, default: {}, null: false, comment: "Settings"
  end
end
