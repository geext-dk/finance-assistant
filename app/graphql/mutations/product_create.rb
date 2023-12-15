# frozen_string_literal: true

module Mutations
  class ProductCreate < BaseMutation
    null true
    argument :name, String
    argument :country, String
    argument :quantity_type, Types::QuantityTypeType

    type Types::ProductType

    def resolve(name:, country:, quantity_type:)
      Products::Create.call(name: name, country: country, quantity_type: quantity_type, user: current_user)
    end
  end
end
