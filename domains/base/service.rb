# frozen_string_literal: true

# @see attribute types: https://api.rubyonrails.org/classes/ActiveModel/Type.html
class Base::Service
  include ActiveModel::Attributes
  include ActiveModel::Model

  def initialize(options = {}) # rubocop:disable Style/OptionHash
    @attributes = self.class._default_attributes.deep_dup
    assign_attributes(options)
  end

  # @return [Base::Service]
  def call
    return self unless valid?

    yield

    self
  end

  # @return [boolean]
  def success?
    errors.empty?
  end

  private

  # @param other_errors [ActiveModel::Errors]
  # @return [ActiveModel::Errors] other_errors
  def merge_errors(other_errors)
    other_errors.each { |e| errors.objects.append(e) }
  end

  # @param service [Base::Service]
  # @return [Base::Service]
  def use_service(service)
    merge_errors(service.call.errors)

    service
  end
end
