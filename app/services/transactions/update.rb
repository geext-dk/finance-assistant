# frozen_string_literal: true

module Transactions
  class Update < BaseAuthorizedUserService
    def initialize(transaction_id:, date:, user:)
      super(user)
      @transaction_id = transaction_id
      @date = date
    end

    def call
      transaction = Repository.get(@transaction_id, user_id: user.id)

      Repository.update(transaction, { :date => @date })
    end
  end
end
