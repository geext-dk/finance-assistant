# frozen_string_literal: true

module Accounts
  class Update < BaseAuthorizedUserService
    def initialize(account_id:, name:, user:)
      super(user)
      @account_id = account_id
      @name = name
    end

    def call
      account = Accounts::Repository.get(@account_id, user_id: user.id)

      Accounts::Repository.update(account, :name => @name)
    end
  end
end
