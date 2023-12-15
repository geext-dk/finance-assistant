# frozen_string_literal: true

module Types
  class TransactionType < Types::BaseObject
    field :id, ID, null: false
    field :country, String, null: false
    field :currency, String, null: false
    field :merchant_id, ID, null: false
    field :account_id, ID, null: false
    field :date, GraphQL::Types::ISO8601DateTime, null: false
    field :line_items, [Types::TransactionLineItemType], null: false

    field :merchant, Types::MerchantType, null: false
    def merchant
      Merchants::Repository.get(merchant_id, include_archived: true)
    end

    field :account, Types::AccountType, null: false
    def account
      Accounts::Repository.get(account_id, include_archived: true)
    end
  end
end
