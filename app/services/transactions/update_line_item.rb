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
      transaction = Repository.get(@transaction_id, user_id: user.id)

      line_item = transaction.line_items.find_by(product_id: @product_id)

      if line_item.nil?
        raise ApplicationError.new("Transaction #{@transaction_id} already has no line item for product #{@product_id}")
      end

      product = Products::Repository.get(@product_id, user_id: user.id)

      fraction_digits = Common::CurrencyHelper.get_fraction_digits

      begin
        result = Repository.update_line_item(
          line_item,
          quantity_weighted: product.per_piece? ? nil : @quantity,
          quantity_pieces: product.per_piece? ? @quantity.to_i : nil,
          price_cents: (@price * (10 ** fraction_digits)).to_i,
          discounted_price_cents: (@discounted_price * (10 ** fraction_digits)).to_i,
          total_price_cents: (@total_price * (10 ** fraction_digits)).to_i,
          )

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
