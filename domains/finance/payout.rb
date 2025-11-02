# frozen_string_literal: true

# Cheques for payments to workers.
class Finance::Payout < Base::Model
  with_options inverse_of: "payouts" do
    belongs_to :worker, class_name: "Work::Worker"
  end

  with_options inverse_of: "payout" do
    has_many :logs, class_name: "Work::Log", dependent: :nullify
  end

  has_many :requirements, through: :logs, source: :requirement

  before_validation do
    Rails.logger.error(inspect) # TODO: remove
    self.rate ||= Work::Worker.find_by(id: worker_id)&.rate
  end
end
