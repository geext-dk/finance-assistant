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
      transaction = capture_not_found(@transaction_id, Constants::TRANSACTION_TYPE_NAME) do
        Transaction.for_user(user.id).includes(:line_items).find(@transaction_id)
      end

      line_item = transaction.line_items.find { |li| li.product_id == @product_id }

      if line_item.nil?
        raise NotFoundError.new(
          @product_id, Constants::TRANSACTION_LINE_ITEM_TYPE_NAME,
          message: "Couldn't find line item with product #{@product_id} in transaction #{@transaction_id}")
      end

      transaction.line_items.destroy(line_item)

      transaction
    end
  end
end
