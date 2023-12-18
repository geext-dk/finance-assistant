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
      merchant = capture_not_found(@merchant_id, Merchants::Constants::MERCHANT_TYPE_NAME) do
        Merchant.existing.for_user(user.id).find(@merchant_id)
      end

      account = capture_not_found(@account_id, Accounts::Constants::ACCOUNT_TYPE_NAME) do
        Account.existing.for_user(user.id).find(@account_id)
      end

      Transaction.create(
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
