# frozen_string_literal: true

module Transactions
  class RemoveLineItem < BaseAuthorizedUserService
    # @param [String] transaction_id
    # @param [String] product_id
    def initialize(transaction_id:, product_id:, user:)
      super(user)
      @transaction_id = transaction_id
      @product_id = product_id
    end

    # @return [Transaction]
    def call
      transaction = Repository.get(@transaction_id, user_id: user.id)

      line_item = transaction.line_items.find { |li| li.product_id == @product_id }

      unless line_item.nil?
        transaction.line_items.destroy(line_item)
      end
      # TODO add logging if line item was not deleted because it doesn't exist

      transaction
    end
  end
end
