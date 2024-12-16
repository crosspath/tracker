# frozen_string_literal: true

require_relative "../../lib/settings"

AppConfig = Settings.configurate { file("config/settings.yml") }.freeze
