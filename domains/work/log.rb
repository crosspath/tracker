# frozen_string_literal: true

# Records of performed work.
class Work::Log < Base::Model
  with_options inverse_of: "reviews" do
    belongs_to :worker, class_name: "Work::Worker"
    belongs_to :requirement, class_name: "Goals::Requirement"
  end
end
