# frozen_string_literal: true

# Manage work logs.
class Work::LogsController < ApplicationController
  ALLOWED_ATTRIBUTES = %w[ended_at kind planned_duration requirement_id started_at worker_id].freeze

  private_constant :ALLOWED_ATTRIBUTES

  crud do
    attributes ALLOWED_ATTRIBUTES
    class_name "Work::Log"
    item_name :work_log
    index_path { work_logs_path }
    new_path { new_work_log_path }
    show_path { work_log_path(@work_log) }
  end

  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :init_copy_service, only: :show
  # rubocop:enable Rails/LexicallyScopedActionFilter

  # Create new or copy existing record.
  def create
    original_id = params.dig(:work_log, :copy_from)
    return super if original_id.blank?

    original = find_record_or_redirect(original_id)
    return if original.nil?

    copy_record(original)
  end

  # List records of work logs.
  def index
    @filter = Work::Log.new(kind: nil, **filter_params)
    @work_logs =
      Work::Log
        .includes(:payout, :requirement, :worker)
        .joins(:worker)
        .order(requirement_id: :desc, kind: :asc, "work_workers.position": :asc)

    FILTER_ATTRIBUTES.each do |k|
      @work_logs = @work_logs.where(k => @filter[k]) if @filter[k]
    end
  end

  # Show form for new record.
  def new
    @work_log = Work::Log.new(kind: nil, **filter_params)
  end

  private

  FILTER_ATTRIBUTES = %i[kind requirement_id worker_id].freeze

  private_constant :FILTER_ATTRIBUTES

  # @param original [Work::Log]
  # @return [void]
  def copy_record(original)
    copy_service =
      Work::Services::Logs::Copy.new(log: original, new_values: values_for_new_copy).call
    return redirect_to_work_log(copy_service.copy.id) if copy_service.success?

    flash[:alert] = "Error(s) occured: #{copy_service.errors.to_hash.to_json}"
    redirect_to_work_log(original.id)
  end

  # @return [Hash-like]
  def filter_params
    params.key?(:work_log) ? params.expect(work_log: FILTER_ATTRIBUTES) : {}
  end

  # @param id [Integer]
  # @return [Work::Log, nil]
  def find_record_or_redirect(id)
    log = Work::Log.find_by(id:)
    return log if log

    redirect_to(work_logs_path, alert: "Cannot find Work::Log ##{id}")
    nil
  end

  # Initialize record values for copy.
  def init_copy_service
    @copy_presenter = Work::Services::Logs::Copy.new(log: @work_log)
  end

  # @param id [Integer]
  # @return [void]
  def redirect_to_work_log(id)
    redirect_to(work_log_path(id))
  end

  # @return [Hash]
  def values_for_new_copy
    params.require(:work_log).permit(*ALLOWED_ATTRIBUTES).to_hash.symbolize_keys
  end
end
