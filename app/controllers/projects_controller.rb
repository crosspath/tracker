# frozen_string_literal: true

# Manage projects list.
class ProjectsController < ApplicationController
  crud do
    attributes %w[description title]
    class_name "Goals::Project"
    item_name :project
    index_path { projects_path }
    new_path { new_project_path }
    show_path { project_path(@project) }
  end

  # List records of projects.
  def index
    @projects = Goals::Project.order(:title)
  end

  # Show form for existing record.
  def show
    super
    @requirements = @project.requirements
  end
end
