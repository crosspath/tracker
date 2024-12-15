# frozen_string_literal: true

# Base class for batch processing. You may use it for updating many record in he database.
class Base::BatchService
  SLICE = 100

  # @param debug [boolean]
  def initialize(debug: false, slice: SLICE)
    @debug = debug
    @slice = slice
  end

  # @param skip_ids [Array<Integer>, nil]
  # @return [void]
  def call(skip_ids: nil)
    selected_ids = find_ids
    selected_ids -= skip_ids if skip_ids

    print_total_count(selected_ids) if @debug
    apply_to_ids(selected_ids)
  end

  private

  # @param selected_ids [Array<Integer>]
  # @return [void]
  def apply_to_ids(_selected_ids)
    raise NotImplementedError
  end

  # @return [Array<Integer>]
  def find_ids
    raise NotImplementedError
  end

  # @param klass [ActiveRecord::Relation, ActiveRecord::Base]
  # @param object_ids [Array<Integer>]
  # @yieldparam obj [ActiveRecord::Base]
  # @yieldparam index [String]
  # @return [void]
  def portion(klass, object_ids)
    index = 1
    digits = Math.log10(project_ids + 1).floor + 1 # Amount of digits of maximum index value.

    object_ids.each_slice(@slice) do |ids|
      klass.where(id: ids).each do |obj| # rubocop:disable Rails/FindEach
        yield obj, index.to_s.rjust(digits)
        index += 1
      end
    end
  end

  # @param selected_ids [Array<Integer>]
  # @return [void]
  def print_total_count(_selected_ids)
    raise NotImplementedError
  end
end
