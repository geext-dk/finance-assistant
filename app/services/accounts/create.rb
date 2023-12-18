# frozen_string_literal: true

module Accounts
  class Create < BaseAuthorizedUserService
    def initialize(name:, currency:, user:)
      super(user)
      @name = name
      @currency = currency
    end

    def call
      account = Account.create(name: @name, currency: @currency, user_id: user.id)

      unless account.valid?
        raise ApplicationError.new("Couldn't create account", account.errors.full_messages)
      end

      account
    end
  end
end
