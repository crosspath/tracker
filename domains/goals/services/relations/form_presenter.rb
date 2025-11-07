# frozen_string_literal: true

# Collects data from configuration file & database.
class Goals::Services::Relations::FormPresenter < Base::Service
  attribute :requirement # Goals::Requirement

  attr_reader :grouped_requirement_kinds, :requirements_for_select

  validates :requirement, presence: true

  # @return [self]
  def call
    super do
      @grouped_requirement_kinds = MapRelationKindsAndRequirementKinds.new(requirement.kind)
      requirement_kinds = @grouped_requirement_kinds.requirement_kinds

      @requirements_for_select =
        MapRequirementKindsAndRequirements.new(requirement, requirement_kinds)
    end
  end

  # Container for relation kinds that may be used for selected requirement kind,
  # and available requirement kinds for these relation kinds.
  class MapRelationKindsAndRequirementKinds
    Item = Struct.new(:relation_kind, :requirement_kinds)

    # @param requirement_kind [String]
    def initialize(requirement_kind)
      @config = AppConfig.requirement_relations
      @kind = requirement_kind
      @left = []
      @right = []

      fill_data
    end

    # @return [Array<Hash<Symbol, String>>]
    #   Example: `[{direction: :left, rel: :includes, req: "user_story"}, ...]` for feature
    def relation_kind_attributes
      collect_attributes(@left, "left") + collect_attributes(@right, "right")
    end

    # @return [Array<String>]
    def relation_kind_comments
      collect_comments(@left, "left") + collect_comments(@right, "right")
    end

    # @return [Array<String>]
    def requirement_kinds
      (@left.flat_map(&:requirement_kinds) + @right.flat_map(&:requirement_kinds)).uniq
    end

    private

    # @param items [Array<Item>]
    # @param direction [String]
    # @return [Array<Hash<Symbol, String>>]
    def collect_attributes(items, direction)
      items.map { |item| {direction:, rel: item.relation_kind.to_s, reqs: item.requirement_kinds} }
    end

    # @param items [Array<Item>]
    # @param direction [String]
    # @return [Array<String>]
    def collect_comments(items, direction)
      items.map { |item| @config[item.relation_kind]["comment_for_#{direction}"] }
    end

    # @return [void]
    def fill_data # rubocop:disable Metrics/AbcSize
      @config.each_pair do |key, options|
        left_req_kinds = []
        right_req_kinds = []
        options.requirement_kinds.each do |item|
          left_req_kinds << item.right if item.left == @kind
          right_req_kinds << item.left if item.right == @kind
        end
        @left << Item.new(key, left_req_kinds) if !left_req_kinds.empty?
        @right << Item.new(key, right_req_kinds) if !right_req_kinds.empty?
      end
    end
  end

  # Prepares options for selecting requirements.
  class MapRequirementKindsAndRequirements
    attr_reader :requirement_options

    # @param requirement [Goals::Requirement]
    # @param requirement_kinds [Array<String>]
    def initialize(requirement, requirement_kinds)
      comments = AppConfig.requirements.to_h { |k, v| [k.to_s, v.comment] }

      @requirement_options =
        grouped_requirements(requirement, requirement_kinds).map do |kind, items|
          items.delete(1) # kind
          {kind:, comment: comments[kind], options: items}
        end
    end

    private

    # @param requirement_id [Integer]
    # @return [Array<Integer>]
    def already_linked_requirement_ids(requirement_id)
      Goals::RequirementRelation.either_side(requirement_id).pluck(:left_id, :right_id).flatten.uniq
    end

    # @param requirement [Goals::Requirement]
    # @param requirement_kinds [Array<String>]
    # @return [Hash<String, Array<Array(String, String, Integer)>>]
    #   Example: `{"task" => [["Task name", "task", 1], ...]}`
    def grouped_requirements(requirement, requirement_kinds)
      requirement.project.requirements
        .where(kind: requirement_kinds)
        .where.not(id: already_linked_requirement_ids(requirement.id))
        .order(:position)
        .pluck(:title, :kind, :id)
        .group_by(&:second)
    end
  end

  private_constant :MapRelationKindsAndRequirementKinds, :MapRequirementKindsAndRequirements
end
