# frozen_string_literal: true

module Mutations
  class TransactionRemoveLineItem < BaseMutation
    null true
    argument :transaction_id, ID
    argument :product_id, ID

    type Types::TransactionType

    def resolve(transaction_id:, product_id:)
      Transactions::RemoveLineItem.call(transaction_id: transaction_id, product_id: product_id, user: current_user)
    end
  end
end
