# frozen_string_literal: true

module Mutations
  class ProductUpdate < BaseMutation
    null true
    argument :product_id, ID
    argument :name, String

    type Types::ProductType

    def resolve(product_id:, name:)
      Products::Update.call(product_id: product_id, name: name, user: current_user)
    end
  end
end
