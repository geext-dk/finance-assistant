# frozen_string_literal: true

module Merchants
  class Update < BaseAuthorizedUserService
    def initialize(merchant_id:, name:, user:)
      super(user)
      @merchant_id = merchant_id
      @name = name
    end

    def call
      merchant = Merchants::Repository.get(@merchant_id, user_id: user.id)

      Merchants::Repository.update(merchant, :name => @name)
    end
  end
end
