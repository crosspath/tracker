# frozen_string_literal: true

# Helper class for passing any atribute value without conversions.
class Types::NonSerializable < ActiveModel::Type::Value
  # Cast value to... the same value.
  def cast(value)
    value
  end

  # Is not supported.
  def deserialize(_value)
    raise NotImplementedError
  end

  # Is not supported.
  def serializable?(_value)
    false
  end

  # Is not supported.
  def serialize(_value)
    raise NotImplementedError
  end

  # Type name for word `attribute` in DSL of ActiveModel.
  def type
    :non_serializable
  end
end
