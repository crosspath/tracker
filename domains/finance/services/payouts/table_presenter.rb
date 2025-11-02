# frozen_string_literal: true

# Provides presenter functionality for listing payouts within table.
class Finance::Services::Payouts::TablePresenter < Base::Service
  attribute :payout # Finance::Payout | nil

  def initialize(...)
    super
    @vh = ApplicationController.helpers
    @uh = Rails.application.routes.url_helpers
  end

  # @return [String]
  def link
    if payout
      @vh.link_to("#{payout.id}, #{payout.paid_at || "-"}", @uh.payout_path(payout.id))
    else
      "None"
    end
  end
end
