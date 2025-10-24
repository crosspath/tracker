# frozen_string_literal: true

# Provides presenter functionality for listing requirements within table.
class Goals::Services::Requirements::TablePresenter < Base::Service
  attribute :kind # String
  attribute :requirements # Array<Goals::Requirement>

  attr_reader :optional_data # Hash<Symbol, String>

  def initialize(...)
    super

    @kinds = AppConfig.requirements.members
    @config = @kinds.include?(kind.to_sym) ? AppConfig.requirements[kind] : nil
    @optional_data = fetch_optional_data
  end

  # @return [String]
  def kind_comment
    @config&.comment || kind
  end

  private

  # @return [Hash]
  def fetch_optional_data
    return {} if @config.nil?

    @optional_data =
      @config
        .optional_data
        .to_h { |key, props| [[key, props.comment], props.show_in_table] }
        .filter_map { |k, v| k if v }
        .to_h
  end
end
