# frozen_string_literal: true

Rails.application.configure do
  config.action_controller.allow_forgery_protection = false
  config.action_controller.raise_on_missing_callback_actions = true
  config.action_dispatch.show_exceptions = :rescuable
  # config.action_view.annotate_rendered_view_with_filenames = true
  config.active_support.deprecation = :stderr
  config.cache_store = :null_store
  config.consider_all_requests_local = true
  config.eager_load = ENV["CI"].present?
  config.enable_reloading = false
  # config.i18n.raise_on_missing_translations = true
  config.public_file_server.headers = {"cache-control" => "public, max-age=3600"}
end
