# frozen_string_literal: true

module Mutations
  class TransactionUpdateLineItem < BaseMutation
    null true
    argument :transaction_id, ID
    argument :product_id, ID
    argument :quantity, Float
    argument :price, Float
    argument :discounted_price, Float, required: false
    argument :total_price, Float

    type Types::TransactionType

    def resolve(transaction_id:, product_id:, quantity:, price:, discounted_price:, total_price:)
      Transactions::UpdateLineItem.call(
        user: current_user,
        transaction_id: transaction_id,
        product_id: product_id,
        quantity: quantity,
        price: price,
        discounted_price: discounted_price,
        total_price: total_price
      )
    end
  end
end
