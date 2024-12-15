# frozen_string_literal: true

# @see attribute types: https://api.rubyonrails.org/classes/ActiveModel/Type.html
class Base::Query
  include ActiveModel::AttributeAssignment
  include ActiveModel::Attributes

  def initialize(**options)
    @attributes = self.class._default_attributes.deep_dup
    assign_attributes(options)
  end

  # @return [ActiveRecord::Relation, Base::Model]
  def call
    raise NotImplementedError
  end
end
