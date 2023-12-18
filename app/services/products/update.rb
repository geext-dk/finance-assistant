# frozen_string_literal: true

module Products
  class Update < BaseAuthorizedUserService
    def initialize(product_id:, name:, user:)
      super(user)
      @product_id = product_id
      @name = name
    end

    def call
      product = capture_not_found(@product_id, Constants::PRODUCT_TYPE_NAME) do
        Product.existing.for_user(user.id).find(@product_id)
      end

      unless product.update(name: @name)
        raise ApplicationError.new("Couldn't update product '#{@product_id}'", product.errors.full_messages)
      end

      product
    end
  end
end
