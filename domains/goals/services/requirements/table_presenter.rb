# frozen_string_literal: true

# Provides presenter functionality for listing requirements within table.
class Goals::Services::Requirements::TablePresenter < Base::Service
  attribute :kind # String
  attribute :project # Goals::Project
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

  # @return [Hash<Symbol, String>]
  def fetch_optional_data
    return {} if @config.nil?

    project
      .config_for_optional_data_for_requirements[kind]
      .select { |_, props| props.show_in_table }
      .transform_values(&:comment)
  end
end
