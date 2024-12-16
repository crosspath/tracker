# frozen_string_literal: true

# Manage workers list.
class WorkersController < ApplicationController
  crud do
    attributes %w[payment_info position rate title]
    class_name "Work::Worker"
    item_name :worker
    index_path { workers_path }
    new_path { new_worker_path }
    show_path { worker_path(@worker) }
  end

  # List records of workers.
  def index
    @workers = Work::Worker.order(:position)
  end
end
