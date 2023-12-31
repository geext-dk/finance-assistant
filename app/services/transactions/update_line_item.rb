# frozen_string_literal: true

module Transactions
  class UpdateLineItem < BaseAuthorizedUserService
    attr_accessor :transaction_id, :product_id, :quantity, :price, :discounted_price, :total_price

    validates :transaction_id, presence: true
    validates :product_id, presence: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :price, presence: true
    validates :total_price, presence: true

    def initialize(transaction_id:, product_id:, quantity:, price:, discounted_price: nil, total_price:, user:)
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

      line_item = transaction.line_items.find { |li| li.product_id == @product_id }

      if line_item.nil?
        raise NotFoundError.new(
          @product_id,
          Constants::TRANSACTION_TYPE_NAME,
          message: "Transaction #{@transaction_id} has no line item for product #{@product_id}")
      end

      product = capture_not_found(@product_id, Products::Constants::PRODUCT_TYPE_NAME) do
        Product.for_user(user.id).find(@product_id)
      end

      fraction_digits = Common::CurrencyHelper.get_fraction_digits

      begin
        result = line_item.update(
          quantity_weighted: product.per_piece? ? nil : @quantity,
          quantity_pieces: product.per_piece? ? @quantity.to_i : nil,
          price_cents: (@price * (10 ** fraction_digits)).round,
          discounted_price_cents: (@discounted_price.nil? ? nil : (@discounted_price * (10 ** fraction_digits)).round),
          total_price_cents: (@total_price * (10 ** fraction_digits)).round)

        if result
          transaction
        else
          raise ApplicationError.new(
                  "Couldn't update line item with product #{@product_id} in transaction #{@transaction_id}",
                  line_item.errors.full_messages)
        end
      rescue ActiveRecord::ActiveRecordError => error
        raise ApplicationError.new("Couldn't create a line item in transaction #{@transaction_id}", error)
      end
    end
  end
end
