# frozen_string_literal: true

module Transactions
  class GetLineItemsByTransactionIds < BaseAuthorizedUserService
    def initialize(user:, transaction_ids:)
      super(user)
      @transaction_ids = transaction_ids
    end

    def call
      TransactionLineItem.includes(:owner_transaction).where(
        owner_transaction_id: @transaction_ids,
        owner_transaction: { user_id: user.id })
    end
  end
end
