# frozen_string_literal: true

module Transactions
  class UpdateLineItem < BaseAuthorizedUserService
    def initialize(transaction_id:, product_id:, quantity:, price:, discounted_price:, total_price:, user:)
      super(user)
      @transaction_id = transaction_id
      @product_id = product_id
      @quantity = quantity
      @price = price
      @discounted_price = discounted_price
      @total_price = total_price
    end

    # @return [Transaction]
    def call
      transaction = capture_not_found(@transaction_id, Constants::TRANSACTION_TYPE_NAME) do
        Transaction.includes(:line_items).for_user(user.id).find(@transaction_id)
      end

      line_item = transaction.line_items.find_by(product_id: @product_id)

      if line_item.nil?
        raise ApplicationError.new("Transaction #{@transaction_id} already has no line item for product #{@product_id}")
      end

      # TODO cover case when a product is archived but it wasn't changed - it should work but it won't
      product = capture_not_found(@product_id, Products::Constants::PRODUCT_TYPE_NAME) do
        Product.existing.for_user(user.id).find(@product_id)
      end

      fraction_digits = Common::CurrencyHelper.get_fraction_digits

      begin
        result = line_item.update(
          quantity_weighted: product.per_piece? ? nil : @quantity,
          quantity_pieces: product.per_piece? ? @quantity.to_i : nil,
          price_cents: (@price * (10 ** fraction_digits)).to_i,
          discounted_price_cents: (@discounted_price * (10 ** fraction_digits)).to_i,
          total_price_cents: (@total_price * (10 ** fraction_digits)).to_i)

        if result
          transaction
        else
          raise ApplicationError.new(
                  "Couldn't create a line item in transaction #{@transaction_id}",
                  line_item.errors.full_messages)
        end
      rescue ActiveRecord::ActiveRecordError => error
        raise ApplicationError.new("Couldn't create a line item in transaction #{@transaction_id}", error)
      end
    end
  end
end
