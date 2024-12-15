# frozen_string_literal: true

# @see attribute types: https://api.rubyonrails.org/classes/ActiveModel/Type.html
class Base::Form < Base::Service
  attr_reader :object

  delegate :id, :persisted?, to: :object, allow_nil: true

  # @return [boolean]
  def success?
    @object&.persisted?
  end
end
