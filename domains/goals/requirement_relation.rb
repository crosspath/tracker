# frozen_string_literal: true

# Relations between project requirements.
class Goals::RequirementRelation < Base::Model
  with_options inverse_of: "relations" do
    belongs_to :left, class_name: "Goals::Requirement"
    belongs_to :right, class_name: "Goals::Requirement"
  end

  validates :kind, inclusion: {in: %w[starts_after includes]}
end
