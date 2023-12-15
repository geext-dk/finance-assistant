# frozen_string_literal: true

module Merchants
  class Get < BaseAuthorizedUserService
    def initialize(merchant_id:, user:)
      super(user)
      @merchant_id = merchant_id
    end

    def call
      Merchants::Repository.get(@merchant_id, user_id: user.id)
    end
  end
end
