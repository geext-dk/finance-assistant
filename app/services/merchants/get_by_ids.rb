# frozen_string_literal: true

module Merchants
  class GetByIds < BaseAuthorizedUserService
    def initialize(merchant_ids:, user:, include_archived: false)
      super(user)
      @merchant_ids = merchant_ids
      @include_archived = include_archived
    end

    def call
      Merchant.with_archived(@include_archived).for_user(user.id).where(id: @merchant_ids)
    end
  end
end
