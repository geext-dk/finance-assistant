# frozen_string_literal: true

module Mutations
  class ProductArchive < BaseMutation
    null true
    argument :product_id, ID

    type Types::ProductType

    def resolve(product_id:)
      Products::Archive.call(product_id: product_id, user: current_user)
    end
  end
end
