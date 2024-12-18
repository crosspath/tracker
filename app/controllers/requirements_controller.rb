# frozen_string_literal: true

# Manage requirements list.
class RequirementsController < ApplicationController
  before_action :find_project

  crud do
    attributes %w[description kind position title], {"optional_data" => {}}
    class_name "Goals::Requirement"
    item_name :requirement
    index_path { project_requirements_path(project_id: @project.id) }
    new_path { new_project_requirements_path(project_id: @project.id) }
    show_path { project_requirement_path(project_id: @project.id, id: @requirement.id) }
  end

  # List records of requirements within selected project.
  def index
    @requirements = @project.requirements.order(:position)
  end

  # Show form for existing record.
  def show
    super
    @relations_on_left = @requirement.relations_on_left.includes(:right)
    @relations_on_right = @requirement.relations_on_right.includes(:left)
  end

  private

  # Find record in table.
  def find_object
    self.object = @project.requirements.find(params[:id])
  end

  # Find project in table. Visibility scope for requirements is limited by project.
  def find_project
    @project = Goals::Project.find(params[:project_id])
  end

  # Initialize empty object.
  def init_object
    self.object = @project.requirements.new
  end

  # Set attributes in object (from params hash).
  def set_attributes_from_params
    super
    object.optional_data = object.optional_data[object.kind] || {}
  end
end
