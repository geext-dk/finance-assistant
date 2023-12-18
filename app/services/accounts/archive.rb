# frozen_string_literal: true

module Accounts
  class Archive < BaseAuthorizedUserService
    def initialize(user:, account_id:)
      super(user)

      @account_id = account_id
    end

    def call
      account = capture_not_found(@account_id, Constants::ACCOUNT_TYPE_NAME) do
        Account.existing.for_user(user.id).find(@account_id)
      end

      account.archive

      account
    end
  end
end
