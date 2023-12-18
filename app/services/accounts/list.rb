# frozen_string_literal: true

module Accounts
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end

    def call
      logger.debug "Getting a list of accounts for user #{user.id}"

      Account.existing.for_user(user.id)
    end
  end
end
