# frozen_string_literal: true

module Types
  class TransactionType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :country, String, null: false
    field :currency, String, null: false
    field :merchant_id, ID, null: false
    field :account_id, ID, null: false
    field :date, GraphQL::Types::ISO8601DateTime, null: false
    field :line_items, [Types::TransactionLineItemType], null: false
    def line_items
      dataloader.with(Sources::LineItemsByTransactionIds, user: context[:current_user]).load(object.id)
    end

    field :merchant, Types::MerchantType, null: false
    def merchant
      dataloader.with(Sources::MerchantsByIds, user: context[:current_user], include_archived: true).load(object.merchant_id)
    end

    field :account, Types::AccountType, null: false
    def account
      dataloader.with(Sources::AccountsByIds, user: context[:current_user], include_archived: true).load(object.account_id)
    end
  end
end
