# frozen_string_literal: true

module Merchants
  class Archive < BaseAuthorizedUserService
    def initialize(merchant_id:, user:)
      super(user)
      @merchant_id = merchant_id
    end

    def call
      merchant = Merchants::Repository.get(@merchant_id, user_id: user.id)

      Merchants::Repository.update(merchant, { archived_at: Time.now.utc })
    end
  end
end
