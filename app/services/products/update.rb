# frozen_string_literal: true

module Products
  class Update < BaseAuthorizedUserService
    def initialize(product_id:, name:, user:)
      super(user)
      @product_id = product_id
      @name = name
    end

    def call
      product = Products::Repository.get(@product_id, user_id: user.id)

      Products::Repository.update(product, :name => @name)
    end
  end
end
