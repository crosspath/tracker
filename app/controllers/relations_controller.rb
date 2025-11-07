# frozen_string_literal: true

# Manage requirements relations list.
class RelationsController < ApplicationController
  before_action :find_project
  before_action :find_requirement

  crud do
    actions %i[create new]
    attributes %w[kind left_id right_id]
    class_name "Goals::RequirementRelation"
    item_name :relation
    index_path { project_requirement_path(project_id: @project.id, id: @requirement.id) }
    new_path do
      new_project_requirement_path(project_id: @project.id, requirement_id: @requirement.id)
    end
    show_path { project_requirement_path(project_id: @project.id, id: @requirement.id) }
  end

  # params:
  #   ids [Array<Integer>] IDs of Goals::RequirementRelation
  def delete
    relation_scope.where(id: params[:ids]).delete_all

    redirect_to(object_path(:index))
  end

  private

  # Find record in table.
  def find_object
    self.object = relation_scope.find(params[:id])
  end

  # Find project in table. Visibility scope for requirements is limited by project.
  def find_project
    @project = Goals::Project.find(params[:project_id])
  end

  # Find requirement in table.
  def find_requirement
    @requirement = @project.requirements.find(params[:requirement_id])
  end

  # Initialize empty object.
  def init_object
    self.object = Goals::RequirementRelation.new(left: @requirement)
  end

  # @return [Goals::RequirementRelation::Relation]
  def relation_scope
    Goals::RequirementRelation.either_side(@requirement.id)
  end
end
