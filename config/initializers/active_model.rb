# frozen_string_literal: true

require_relative "../../lib/types"
require_relative "../../lib/types/non_serializable"

ActiveModel::Type.register(:non_serializable, Types::NonSerializable)
