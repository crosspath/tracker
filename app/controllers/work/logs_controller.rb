# frozen_string_literal: true

# Manage work logs.
class Work::LogsController < ApplicationController
  crud do
    attributes %w[ended_at kind planned_duration requirement_id started_at worker_id]
    class_name "Work::Log"
    item_name :work_log
    index_path { work_logs_path }
    new_path { new_work_log_path }
    show_path { work_log_path(@work_log) }
  end

  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :fetch_records_for_associations, only: %i[new show]
  # rubocop:enable Rails/LexicallyScopedActionFilter

  # List records of work logs.
  def index
    @work_logs = Work::Log.includes(:payout, :requirement, :worker).order(started_at: :desc)
  end

  private

  # Fetch records required for forms.
  def fetch_records_for_associations
    @requirements =
      Goals::Requirement
        .includes(:project)
        .where(kind: requirement_kinds_as_unit_of_work)
        .order(:project_id, :kind, :position)
    @workers = Work::Worker.order(:position, :title)
  end

  # @return [Array<String>]
  def requirement_kinds_as_unit_of_work
    items = AppConfig.requirements
    items.members.select { |k| items[k].unit_of_work }
  end
end
