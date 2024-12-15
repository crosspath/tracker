# frozen_string_literal: true

# Base class for ActiveRecord models.
class Base::Model < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  primary_abstract_class
end
