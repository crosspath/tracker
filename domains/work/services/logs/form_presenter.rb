# frozen_string_literal: true

# Provides presenter functionality for creating/updating/filtering work logs.
class Work::Services::Logs::FormPresenter < Base::Service
  attribute :form # ActionView::Helpers::FormBuilder

  # Fetch records required for forms.
  def initialize(...)
    super
    @log = form.object
    @vh = ApplicationController.helpers
  end

  # @param include_blank [boolean]
  # @return [String]
  def select_kind(include_blank: false)
    @kinds ||= AppConfig.work_logs.to_h { |k, v| [v.comment, k] }

    form.select(:kind, @kinds, include_blank:)
  end

  # @param include_blank [boolean]
  # @return [String]
  def select_requirement(include_blank: false)
    @requirements ||=
      Goals::Requirement
        .includes(:project)
        .where(kind: requirement_kinds_as_unit_of_work)
        .order(:project_id, :kind, :position)

    options = @requirements.map { |req| ["#{req.project.title} - #{req.title}", req.id] }

    form.select(:requirement_id, options, include_blank:)
  end

  # @param include_blank [boolean]
  # @return [String]
  def select_worker(include_blank: false)
    @workers ||= Work::Worker.order(:position, :title)
    options = @vh.options_from_collection_for_select(@workers, :id, :title, @log.worker_id)

    form.select(:worker_id, options, include_blank:)
  end

  private

  # @return [Array<String>]
  def requirement_kinds_as_unit_of_work
    items = AppConfig.requirements
    items.members.select { |k| items[k].unit_of_work }
  end
end
