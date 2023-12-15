# frozen_string_literal: true

module Accounts
  class Archive < BaseAuthorizedUserService
    def initialize(user:, account_id:)
      super(user)

      @account_id = account_id
    end

    def call
      account = Accounts::Repository.get(@account_id, user_id: user.id)

      Accounts::Repository.update(account, { archived_at: Time.now.utc })
    end
  end
end
