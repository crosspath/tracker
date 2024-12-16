# frozen_string_literal: true

require_relative "../../lib/settings"

AppConfig =
  Settings.configurate do
    file("config/settings.yml")
    file("config/settings.local.yml") if Rails.root.join("config/settings.local.yml").exist?
  end.freeze
