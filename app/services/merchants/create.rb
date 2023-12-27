# frozen_string_literal: true

module Merchants
  class Create < BaseAuthorizedUserService
    def initialize(name:, country:, user:)
      super(user)
      @name = name
      @country = country
    end

    def call
      merchant = Merchant.create(name: @name, country: @country, user_id: user.id)

      unless merchant.valid?
        raise ApplicationError.new("Couldn't create merchant", merchant.errors.full_messages)
      end

      merchant
    end
  end
end
