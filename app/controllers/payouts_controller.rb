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
    @payouts = Finance::Payout.includes(:worker).order(created_at: :desc, worker_id: :asc)
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

  # Fetch records required for forms.
  def fetch_records_for_associations
    @workers = Work::Worker.order(:position, :title)

    payout = @payout.persisted? ? @payout : nil
    @work_logs = Work::Queries::Logs::ForPayouts.new(payout:).call
  end
end
