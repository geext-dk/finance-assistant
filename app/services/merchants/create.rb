# frozen_string_literal: true

module Merchants
  class Create < BaseAuthorizedUserService
    def initialize(name:, country:, user:)
      super(user)
      @name = name
      @country = country
    end

    def call
      Merchants::Repository.create(name: @name, country: @country, user_id: user.id)
    end
  end
end
