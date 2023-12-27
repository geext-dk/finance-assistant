# frozen_string_literal: true

module Types
  class TransactionLineItemType < Types::BaseObject
    field :product_id, ID, null: false
    field :owner_transaction_id, ID, null: false

    field :quantity, Float, null: false
    def quantity
      object.quantity_weighted || object.quantity_pieces
    end

    field :price, Float, null: false
    def price
      (object.price_cents.to_f / (10 ** Common::CurrencyHelper.get_fraction_digits)).round(2)
    end

    field :discounted_price, Float
    def discounted_price
      if object.discounted_price_cents.present?
        (object.discounted_price_cents.to_f / (10 ** Common::CurrencyHelper.get_fraction_digits)).round(2)
      else
        nil
      end
    end

    field :total_price, Float, null: false
    def total_price
      (object.total_price_cents.to_f / (10 ** Common::CurrencyHelper.get_fraction_digits)).round(2)
    end

    field :product, Types::ProductType, null: false
    def product
      dataloader.with(Sources::ProductsByIds, user: context[:current_user], include_archived: true).load(object.product_id)
    end
  end
end
