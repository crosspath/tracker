# frozen_string_literal: true

# Cheques for payments to workers.
class Finance::Payout < Base::Model
  with_options inverse_of: "payouts" do
    belongs_to :worker, class_name: "Work::Worker"
  end

  with_options inverse_of: "payout" do
    has_many :logs, class_name: "Work::Log", dependent: :nullify
  end
end
