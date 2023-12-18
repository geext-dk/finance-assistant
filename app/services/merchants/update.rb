# frozen_string_literal: true

module Merchants
  class Update < BaseAuthorizedUserService
    def initialize(merchant_id:, name:, user:)
      super(user)
      @merchant_id = merchant_id
      @name = name
    end

    def call
      merchant = capture_not_found(@merchant_id, Constants::MERCHANT_TYPE_NAME) do
        Merchant.existing.for_user(user.id).find(@merchant_id)
      end

      unless merchant.update(name: @name)
        raise ApplicationError.new("Couldn't update merchant '#{@merchant_id}'", merchant.errors.full_messages)
      end

      merchant
    end
  end
end
