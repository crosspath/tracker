# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_controller.perform_caching = true
  config.active_record.attributes_for_inspect = [:id]
  config.active_record.dump_schema_after_migration = false
  config.active_support.report_deprecations = false
  # config.asset_host = "http://assets.example.com"
  config.assume_ssl = true
  # config.cache_store = :mem_cache_store
  config.consider_all_requests_local = false
  config.eager_load = true
  config.enable_reloading = false
  config.force_ssl = AppConfig.dig(:action_dispatch, :force_ssl) || false

  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  config.i18n.fallbacks = true
  config.log_level = AppConfig.dig(:active_support, :log_level) || :info
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)
  config.public_file_server.headers = {"cache-control" => "public, max-age=#{1.year.to_i}"}
  config.silence_healthcheck_path = "/up"
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
end
