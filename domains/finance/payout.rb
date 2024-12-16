# frozen_string_literal: true

# Cheques for payments to workers.
class Finance::Payout < Base::Model
  with_options inverse_of: "finance_payouts" do
    belongs_to :worker, class_name: "Work::Worker"
  end
end
