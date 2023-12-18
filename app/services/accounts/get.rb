# frozen_string_literal: true

module Accounts
  class Get < BaseAuthorizedUserService
    def initialize(account_id:, user:, include_archived: false)
      super(user)
      @account_id = account_id
      @include_archived = include_archived
    end

    def call
      capture_not_found(@account_id, Constants::ACCOUNT_TYPE_NAME) do
        Account.with_archived(@include_archived).for_user(user.id).find(@account_id)
      end
    end
  end
end
