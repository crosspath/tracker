# frozen_string_literal: true

# Manage requirements relations list with fixed left side.
class RelationsOnLeftController < ApplicationController
  before_action :find_project
  before_action :find_requirement

  crud do
    actions %i[create new]
    attributes %w[kind right_id]
    class_name "Goals::RequirementRelation"
    item_name :relation
    index_path { project_requirement_path(project_id: @project.id, id: @requirement.id) }
    new_path do
      new_project_requirement_left_path(project_id: @project.id, requirement_id: @requirement.id)
    end
    show_path { project_requirement_path(project_id: @project.id, id: @requirement.id) }
  end

  # params:
  #   ids [Array<Integer>] IDs of Goals::RequirementRelation
  def delete
    @requirement.relations_on_left.where(id: params[:ids]).delete_all

    redirect_to(object_path(:index))
  end

  # Show form for new record.
  def new
    super
    @requirement_kinds_for_relation_kinds = requirement_kinds_for_relation_kinds
    @other_requirements = other_requirements_for_select
  end

  private

  # Find record in table.
  def find_object
    self.object = @requirement.relations_on_left.find(params[:id])
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
    self.object = @requirement.relations_on_left.new
  end

  # @return [Hash<String, Array<Array(String, String, Integer)>>]
  #   Example: `{"task" => [["Task name", "task", 1], ...]}`
  def other_requirements_for_select
    @project.requirements
      .where(kind: @requirement_kinds_for_relation_kinds.values.flatten.uniq)
      .where.not(id: @requirement.id)
      .order(:position)
      .pluck(:title, :kind, :id)
      .group_by(&:second)
  end

  # @return [Hash<Symbol, Array<String>>] Example: `{"includes" => ["task"]}`
  def requirement_kinds_for_relation_kinds
    AppConfig.requirement_relations.to_h do |key, options|
      requirement_kinds =
        options.requirement_kinds.filter_map { |item| item.right if item.left == @requirement.kind }
      [key, requirement_kinds]
    end
  end
end
