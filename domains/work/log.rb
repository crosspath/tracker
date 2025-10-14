# frozen_string_literal: true

# Records of performed work.
class Work::Log < Base::Model
  with_options inverse_of: "logs" do
    belongs_to :payout, class_name: "Finance::Payout", optional: true
    belongs_to :requirement, class_name: "Goals::Requirement"
    belongs_to :worker, class_name: "Work::Worker"
  end

  with_options validate: true do
    enum :kind,
      AppConfig.work_logs.members.to_h { |x| [x, x] },
      default: AppConfig.work_logs.members.first
  end
end
