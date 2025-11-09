# frozen_string_literal: true

# Provides presenter functionality for existing Work::Log and creates its copy.
class Work::Services::Logs::ApplyDefaults < Base::Service
  attribute :log # Work::Log

  attr_reader :config, :requirement

  validate :validate_config

  validates :requirement, presence: true

  def initialize(...)
    super

    @config = AppConfig.work_logs[log.kind]
    @requirement = Goals::Requirement.find_by(id: log.requirement_id)
  end

  # @return [self]
  def call
    super do
      @config.create.each_pair do |log_attr, req_attr| # rubocop:disable Rails/SaveBang
        log[log_attr] = Array.wrap(req_attr).filter_map { |x| value_from_requirement(x) }.first
      end
    end
  end

  private

  # @return [void]
  def validate_config
    errors.add(:config, :blank) if !@config.respond_to?(:create)
  end

  # @param attr_name [String, Symbol]
  # @return [Object]
  def value_from_requirement(attr_name)
    @requirement[attr_name] || @requirement.optional_data[attr_name]
  end
end
