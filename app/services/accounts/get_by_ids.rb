# frozen_string_literal: true

module Accounts
  class GetByIds < BaseAuthorizedUserService
    def initialize(account_ids:, user:, include_archived: false)
      super(user)
      @account_ids = account_ids
      @include_archived = include_archived
    end

    def call
      Account.with_archived(@include_archived).for_user(user.id).where(id: @account_ids)
    end
  end
end
