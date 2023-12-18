# frozen_string_literal: true

module Transactions
  class Update < BaseAuthorizedUserService
    def initialize(transaction_id:, date:, user:)
      super(user)
      @transaction_id = transaction_id
      @date = date
    end

    def call
      transaction = capture_not_found(@transaction_id, Constants::TRANSACTION_TYPE_NAME) do
        Transaction.for_user(user.id).find(@transaction_id)
      end

      unless transaction.update(date: @date)
        raise ApplicationError.new(
          "Couldn't update transaction '#{@transaction_id}'",
          transaction.errors.full_messages)
      end

      transaction
    end
  end
end
