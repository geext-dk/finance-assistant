# frozen_string_literal: true

module Transactions
  class Create < BaseAuthorizedUserService
    # @param [String] merchant_id
    # @param [String] account_id
    # @param [Time] date
    def initialize(merchant_id:, account_id:, date:, user:)
      super(user)
      @merchant_id = merchant_id
      @account_id = account_id
      @date = date
    end

    # @return [Transaction]
    def call
      merchant = Merchants::Repository.get(@merchant_id, user_id: user.id)

      account = Accounts::Repository.get(@account_id, user_id: user.id)

      Repository.create(
        date: @date,
        merchant_id: @merchant_id,
        account_id: @account_id,
        country: merchant.country,
        currency: account.currency,
        user_id: user.id
      )
    end
  end
end
