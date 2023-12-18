# frozen_string_literal: true

module Transactions
  class List < BaseAuthorizedUserService
    def initialize(user:)
      super(user)
    end

    # @return [ActiveRecord::Relation<Transaction>]
    def call
      Transaction.for_user(user.id)
    end
  end
end
