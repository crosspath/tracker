# frozen_string_literal: true

# Common class for representing work activities within project.
class Goals::Requirement < Base::Model
  with_options inverse_of: "requirements" do
    belongs_to :project, class_name: "Goals::Project"
  end

  with_options inverse_of: "requirement" do
    has_many :logs, class_name: "Work::Log", dependent: :delete_all
    has_many :relations, class_name: "Goal::RequirementRelation", dependent: :delete_all
    has_many :reviews, class_name: "Work::Review", dependent: :delete_all
  end

  validates :kind, inclusion: {in: AppConfig.requirements.members.map(&:to_s)}

  before_validation do
    self.position ||= (Goals::Requirement.where(kind:, project_id:).maximum(:position) || -1) + 1
  end
end
