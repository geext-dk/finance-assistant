# frozen_string_literal: true

module Products
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end
    def call
      Product.existing.for_user(user.id)
    end
  end
end
