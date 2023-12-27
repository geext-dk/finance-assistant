# frozen_string_literal: true

module Products
  class Create < BaseAuthorizedUserService
    def initialize(name:, country:, quantity_type:, user:)
      super(user)
      @name = name
      @country = country
      @quantity_type = quantity_type
    end

    def call
      product = Product.create(name: @name, country: @country, quantity_type: @quantity_type, user_id: user.id)

      unless product.valid?
        raise ApplicationError.new("Couldn't create product", product.errors.full_messages)
      end

      product
    end
  end
end
