# frozen_string_literal: true

# A person, who executes project task.
class Work::Worker < Base::Model
  with_options inverse_of: "worker", dependent: :delete_all do
    has_many :logs, class_name: "Work::Log"
    has_many :payouts, class_name: "Finance::Payout"
  end

  validates :title, presence: true

  before_validation { self.position ||= (Work::Worker.maximum(:position) || -1) + 1 }
end
