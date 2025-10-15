# frozen_string_literal: true

# Provides presenter functionality for existing Work::Log and creates its copy.
class Work::Services::Logs::Copy < Base::Service
  attribute :log # Work::Log
  attribute :new_values # Hash<Symbol, String | Float | Integer>

  attr_reader :copy # Work::Log

  def initialize(...)
    super
    self.new_values ||= {}
    @config = AppConfig.work_logs[log.kind].copy
    @copy = Work::Log.new(**attributes_for_copy) if @config
  end

  # @return [self]
  def call
    super { merge_errors(@copy.errors) if !@copy.save }
  end

  # @param key [String, Symbol]
  # @return [boolean]
  def visible?(key)
    @config[key].visible
  end

  private

  # @return [Hash<Symbol, String | Float | Integer | nil>]
  def attributes_for_copy
    new_kind = new_values[:kind]

    @config.to_h do |key, value|
      key = key.to_sym
      [key, attribute_value_for_copy(key, value.value, new_kind)]
    end
  end

  # @param key [Symbol]
  # @param option [String, Array, nil]
  # @param new_kind [String]
  # @return [String | Float | Integer | nil]
  def attribute_value_for_copy(key, option, new_kind) # rubocop:disable Metrics/MethodLength
    return new_values[key] if new_values.key?(key)

    case option
    when "same"
      log[key]
    when nil
      nil
    when Array
      new_kind.nil? ? nil : value_from_config_array(key, option, new_kind)
    else
      raise ArgumentError, "work_logs.#{log.kind}.copy.#{key}.value is #{option.inspect}"
    end
  end

  # @param key [Symbol]
  # @param option [String, Array, nil]
  # @param new_kind [String]
  # @return [String | Float | Integer | nil]
  def value_from_config_array(key, option, new_kind)
    value_option = option.find { |row| row.kind == new_kind }
    return if value_option.nil?

    value_option.member?(:result) ? value_option.result : (value_option.multiply * log[key])
  end
end
