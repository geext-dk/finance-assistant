# frozen_string_literal: true

module Products
  class Get < BaseAuthorizedUserService
    def initialize(product_id:, user:)
      super(user)
      @product_id = product_id
    end

    def call
      Products::Repository.get(@product_id, user_id: user.id)
    end
  end
end
