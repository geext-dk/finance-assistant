# frozen_string_literal: true

module Products
  class GetByIds < BaseAuthorizedUserService
    def initialize(product_ids:, user:, include_archived: false)
      super(user)
      @product_ids = product_ids
      @include_archived = include_archived
    end

    def call
      Product.with_archived(@include_archived).for_user(user.id).where(id: @product_ids)
    end
  end
end
