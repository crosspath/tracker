# frozen_string_literal: true

# Relations between project requirements.
class Goals::RequirementRelation < Base::Model
  with_options class_name: "Goals::Requirement" do
    belongs_to :left, inverse_of: "relations_on_left"
    belongs_to :right, inverse_of: "relations_on_right"
  end

  validates :kind, inclusion: {in: AppConfig.requirement_relations.members.map(&:to_s)}
end
