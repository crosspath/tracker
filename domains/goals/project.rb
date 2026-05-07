# frozen_string_literal: true

# Ordered & managed set of work activities that produces some result to satisfy customer's needs.
class Goals::Project < Base::Model
  with_options inverse_of: "project" do
    has_many :requirements, class_name: "Goals::Requirement", dependent: :delete_all
  end

  validates :title, presence: true

  # @return [Hash<String, Hash<Symbol, Struct>]
  def config_for_optional_data_for_requirements
    return {} if settings["requirements"].blank?

    settings["requirements"].to_h do |kind, fields|
      config = AppConfig.requirements.dig(kind, :optional_data)
      [kind, config ? fields.to_h { |field| [field, config[field]] } : {}]
    end
  end

  # @return [Array<String>]
  def requirement_kinds
    settings["requirements"]&.keys || []
  end

  # @param requirement_kind [String]
  # @return [Array<String>]
  def requirement_optional_data(requirement_kind)
    settings.dig("requirements", requirement_kind.to_s) || []
  end

  # @param params [ActionController:Params]
  # @return [Hash]
  # @example
  #   project.settings = ActionController:Params.new(
  #     requirement_kinds: {"task" => 1, "feature" => 0},
  #     requirement_optional_data: {"task" => {"min_duration" => 1}}
  #   )
  def settings=(params)
    config = AppConfig.requirements
    kinds = config.members.map(&:to_s) & filter_hash_entries(params[:requirement_kinds])

    result =
      kinds.to_h do |x|
        config_fields = config[x].optional_data.members.map(&:to_s)
        [x, config_fields & filter_hash_entries(params[:requirement_optional_data][x])]
      end

    super({"requirements" => result})
  end

  private

  # @param hash [Hash]
  # @return [Array]
  def filter_hash_entries(hash)
    hash&.filter_map { |k, v| k if v == "1" } || []
  end
end
