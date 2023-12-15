# frozen_string_literal: true

module Accounts
  class Get < BaseAuthorizedUserService
    def initialize(account_id:, user:)
      super(user)
      @account_id = account_id
    end

    def call
      Accounts::Repository.get(@account_id, user_id: user.id)
    end
  end
end
