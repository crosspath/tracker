# frozen_string_literal: true

# Common class for representing work activities within project.
class Goals::Requirement < Base::Model
  with_options inverse_of: "requirements" do
    belongs_to :project, class_name: "Goals::Project"
  end

  with_options inverse_of: "requirement" do
    has_many :logs, class_name: "Work::Log", dependent: :delete_all
  end

  with_options class_name: "Goals::RequirementRelation", dependent: :delete_all do
    has_many :relations_on_left, inverse_of: "left"
    has_many :relations_on_right, inverse_of: "right"
  end

  has_many :payouts, through: :logs, source: :payout

  validates :kind, inclusion: {in: AppConfig.requirements.members.map(&:to_s)}
  validates :title, presence: true

  before_validation do
    self.position ||= (Goals::Requirement.where(kind:, project_id:).maximum(:position) || -1) + 1
  end
end
