# frozen_string_literal: true

module Mutations
  class TransactionCreate < BaseMutation
    null true
    argument :account_id, ID
    argument :merchant_id, ID
    argument :date, GraphQL::Types::ISO8601DateTime

    type Types::TransactionType

    def resolve(account_id:, merchant_id:, date:)
      Transactions::Create.call(date: date, account_id: account_id, merchant_id: merchant_id, user: current_user)
    end
  end
end
