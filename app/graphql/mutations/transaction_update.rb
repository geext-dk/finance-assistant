# frozen_string_literal: true

module Mutations
  class TransactionUpdate < BaseMutation
    null true
    argument :transaction_id, ID
    argument :date, GraphQL::Types::ISO8601DateTime

    type Types::TransactionType

    def resolve(transaction_id:, date:)
      Transactions::Update.call(transaction_id: transaction_id, date: date, user: current_user)
    end
  end
end
