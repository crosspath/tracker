# frozen_string_literal: true

# Manage payouts list.
class PayoutsController < ApplicationController
  crud do
    attributes(%w[money paid_at rate worker_id] + [log_ids: []])
    class_name "Finance::Payout"
    item_name :payout
    index_path { payouts_path }
    new_path { new_payout_path }
    show_path { payout_path(@payout) }
  end

  before_action :fetch_records_for_associations, only: %i[new show]

  # List records of payouts.
  def index
    @filter = Finance::Payout.new(filter_params)
    @payouts = Finance::Payout.includes(:worker).order(created_at: :desc, worker_id: :asc)
    @payouts = @payouts.where(worker_id: @filter.worker_id) if @filter.worker_id
  end

  # Show form for new record.
  def new
    super
    @work_log_ids = []
  end

  # Show form for existing record.
  def show
    super
    @work_log_ids = @work_logs.filter_map { |log| log.id if log.payout_id == @payout.id }
  end

  private

  FILTER_ATTRIBUTES = [:worker_id].freeze

  private_constant :FILTER_ATTRIBUTES

  # Fetch records required for forms.
  def fetch_records_for_associations
    @workers = Work::Worker.order(:position, :title)

    payout = @payout.persisted? ? @payout : nil
    @work_logs = Work::Queries::Logs::ForPayouts.new(payout:).call
  end

  # @return [Hash-like]
  def filter_params
    params.key?(:payout) ? params.expect(payout: FILTER_ATTRIBUTES) : {}
  end
end
