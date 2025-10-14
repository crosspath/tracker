# frozen_string_literal: true

# Manage payouts list.
class PayoutsController < ApplicationController
  crud do
    attributes %w[money paid_at worker_id work_log_ids]
    class_name "Finance::Payout"
    item_name :payout
    index_path { payouts_path }
    new_path { new_payout_path }
    show_path { payout_path(@payout) }
  end

  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :fetch_records_for_associations, only: %i[new show]
  # rubocop:enable Rails/LexicallyScopedActionFilter

  # List records of payouts.
  def index
    @payouts = Finance::Payout.includes(:worker).order(created_at: :desc, worker_id: :asc)
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

    @work_logs =
      Work::Log
        .includes(:worker, :requirement)
        .order("work_workers.position": :asc, "work_workers.title": :asc, kind: :asc)
  end
end
