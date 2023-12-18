# frozen_string_literal: true

module Accounts
  class Get < BaseAuthorizedUserService
    def initialize(account_id:, user:)
      super(user)
      @account_id = account_id
    end

    def call
      capture_not_found(@account_id, Constants::ACCOUNT_TYPE_NAME) do
        Account.existing.for_user(user.id).find(@account_id)
      end
    end
  end
end
