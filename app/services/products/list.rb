# frozen_string_literal: true

module Products
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end
    def call
      Products::Repository.list(user_id: user.id)
    end
  end
end
