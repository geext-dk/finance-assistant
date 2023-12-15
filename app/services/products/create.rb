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
      Products::Repository.create(name: @name, country: @country, quantity_type: @quantity_type, user_id: user.id)
    end
  end
end
