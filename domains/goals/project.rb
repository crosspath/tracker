# frozen_string_literal: true

# Ordered & managed set of work activities that produces some result to satisfy customer's needs.
class Goals::Project < Base::Model
  with_options inverse_of: "project" do
    has_many :requirements, class_name: "Goals::Requirement", dependent: :delete_all
  end
end
