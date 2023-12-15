# frozen_string_literal: true

module Transactions
  class Get < BaseAuthorizedUserService
    # @param [String] transaction_id
    def initialize(transaction_id:, user:)
      super(user)
      @transaction_id = transaction_id
    end

    # @return [Transaction]
    def call
      Repository.get(@transaction_id, user_id: user.id)
    end
  end
end
