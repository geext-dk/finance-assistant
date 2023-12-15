# frozen_string_literal: true

module Products
  class Archive < BaseAuthorizedUserService
    def initialize(product_id:, user:)
      super(user)
      @product_id = product_id
    end

    def call
      product = Products::Repository.get(@product_id, user_id: user.id)

      Products::Repository.update(product, archived_at: Time.now.utc)
    end
  end
end
