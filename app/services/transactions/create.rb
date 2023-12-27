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
      if @merchant_id.blank?
        raise ApplicationError.new("Invalid merchant id '#{@merchant_id}'")
      end

      if @account_id.blank?
        raise ApplicationError.new("Invalid account id '#{@account_id}'")
      end

      merchant = capture_not_found(@merchant_id, Merchants::Constants::MERCHANT_TYPE_NAME) do
        Merchant.existing.for_user(user.id).find(@merchant_id)
      end

      account = capture_not_found(@account_id, Accounts::Constants::ACCOUNT_TYPE_NAME) do
        Account.existing.for_user(user.id).find(@account_id)
      end

      transaction = Transaction.create(
        date: @date,
        merchant_id: @merchant_id,
        account_id: @account_id,
        country: merchant.country,
        currency: account.currency,
        user_id: user.id
      )

      unless transaction.valid?
        raise ApplicationError.new("Couldn't create transaction", transaction.errors.full_messages)
      end

      transaction
    end
  end
end
