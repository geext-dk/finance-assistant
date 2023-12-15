# frozen_string_literal: true

module Accounts
  class Create < BaseAuthorizedUserService
    def initialize(name:, currency:, user:)
      super(user)
      @name = name
      @currency = currency
    end

    def call
      Accounts::Repository.create(name: @name, currency: @currency, user_id: user.id)
    end
  end
end
