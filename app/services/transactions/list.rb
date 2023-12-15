# frozen_string_literal: true

module Transactions
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end

    # @return [ActiveRecord::Relation<Transaction>]
    def call
      Repository.list(user_id: user.id)
    end
  end
end
