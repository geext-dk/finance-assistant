# frozen_string_literal: true

module Products
  class Archive < BaseAuthorizedUserService
    def initialize(product_id:, user:)
      super(user)
      @product_id = product_id
    end

    def call
      product = Product.existing.for_user(user.id).find(@product_id)

      product.archive

      product
    rescue ActiveRecord::RecordNotFound
      raise NotFoundError.new(@merchant_id, Constants::PRODUCT_TYPE_NAME)
    end
  end
end
