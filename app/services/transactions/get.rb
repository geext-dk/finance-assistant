# frozen_string_literal: true

module Transactions
  class Get < BaseAuthorizedUserService
    # @param [String] transaction_id
    def initialize(transaction_id:, user:)
      super(user)
      @transaction_id = transaction_id
    end

    def call
      capture_not_found(@transaction_id, Constants::TRANSACTION_TYPE_NAME) do
        Transaction.for_user(user.id).find(@transaction_id)
      end
    end
  end
end
