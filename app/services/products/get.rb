# frozen_string_literal: true

module Products
  class Get < BaseAuthorizedUserService
    def initialize(product_id:, user:)
      super(user)
      @product_id = product_id
    end

    def call
      capture_not_found(@product_id, Constants::PRODUCT_TYPE_NAME) do
        Product.existing.for_user(user.id).find(@product_id)
      end
    end
  end
end
