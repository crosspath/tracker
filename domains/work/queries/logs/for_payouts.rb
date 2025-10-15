# frozen_string_literal: true

# Fetch work logs for payout form.
class Work::Queries::Logs::ForPayouts < Base::Query
  attribute :payout # Finance::Payout | nil

  # @return [Work::Log::ActiveRecord_Relation]
  def call
    result = base_scope

    if payout
      result.where(worker_id: payout.worker_id, payout_id: [nil, payout.id])
    else
      result.where(payout_id: nil)
    end
  end

  private

  # @return [Work::Log::ActiveRecord_Relation]
  def base_scope
    Work::Log
      .includes(:worker, requirement: :project)
      .order("work_workers.position": :asc, "work_workers.title": :asc, kind: :asc)
  end
end
