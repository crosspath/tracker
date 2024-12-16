# frozen_string_literal: true

# Page with dashboard.
class WelcomeController < ApplicationController
  # Root page.
  def index
    @projects = Goals::Project.order(:title)
    @workers = Work::Worker.order(:position)
  end
end
