# frozen_string_literal: true

module Transactions
  class GetLineItemsByTransactionIds < BaseAuthorizedUserService
    def initialize(user:, transaction_ids:)
      super(user)
      @transaction_ids = transaction_ids
    end

    def call
      TransactionLineItem.where(owner_transaction_id: @transaction_ids)
    end
  end
end
