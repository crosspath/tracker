# frozen_string_literal: true

# A person, who executes project task.
class Work::Worker < Base::Model
  with_options inverse_of: "worker" do
    has_many :finance_payouts, class_name: "Finance::Payout", dependent: :delete_all
    has_many :logs, class_name: "Work::Log", dependent: :delete_all
    has_many :reviews, class_name: "Work::Review", dependent: :delete_all
  end

  before_validation { self.position ||= (Work::Worker.maximum(:position) || -1) + 1 }
end
