# frozen_string_literal: true

# Provides presenter functionality for creating/updating/filtering payouts.
class Finance::Services::Payouts::FormPresenter < Base::Service
  attribute :form # ActionView::Helpers::FormBuilder

  # Fetch records required for forms.
  def initialize(...)
    super
    @payout = form.object
    @vh = ApplicationController.helpers
  end

  # @param include_blank [boolean]
  # @return [String]
  def select_worker(include_blank: false)
    @workers ||= Work::Worker.order(:position, :title)
    options = @vh.options_from_collection_for_select(@workers, :id, :title, @payout.worker_id)

    form.select(:worker_id, options, include_blank:)
  end
end
