# frozen_string_literal: true

module Merchants
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end
    def call
      Merchant.existing.for_user(user.id)
    end
  end
end
