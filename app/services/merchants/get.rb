# frozen_string_literal: true

module Merchants
  class Get < BaseAuthorizedUserService
    def initialize(merchant_id:, user:)
      super(user)
      @merchant_id = merchant_id
    end

    def call
      capture_not_found(@merchant_id, Constants::MERCHANT_TYPE_NAME) do
        Merchant.existing.for_user(user.id).find(@merchant_id)
      end
    end
  end
end
