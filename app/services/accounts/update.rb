# frozen_string_literal: true

module Accounts
  class Update < BaseAuthorizedUserService
    def initialize(account_id:, name:, user:)
      super(user)
      @account_id = account_id
      @name = name
    end

    def call
      account = capture_not_found(@account_id, Constants::ACCOUNT_TYPE_NAME) do
        Account.existing.for_user(user.id).find(@account_id)
      end

      unless account.update(name: @name)
        raise ApplicationError.new("Couldn't update account '#{@account_id}'", account.errors.full_messages)
      end

      account
    end
  end
end
