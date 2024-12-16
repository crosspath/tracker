# frozen_string_literal: true

# Base class for ActiveRecord models.
class Base::Model < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  primary_abstract_class

  # @return [Hash<Symbol, String | nil>]
  def self.column_comments
    @column_comments ||= columns_hash.to_h { |col_name, info| [col_name.to_sym, info.comment] }
  end

  # @return [Hash<Symbol, String | nil>]
  def column_comments
    @column_comments ||= self.class.column_comments
  end
end
