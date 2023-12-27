# frozen_string_literal: true

require "test_helper"

class TransactionsListTest < ActiveSupport::TestCase
  test "Should get transactions list" do
    # Arrange
    user = create(:user)
    other_user = create(:user)

    account = create(:account, user: user)
    merchant = create(:merchant, user: user)
    transactions = create_list(:transaction, 5, user: user, merchant: merchant, account: account)

    other_user_account = create(:account, user: other_user)
    other_user_merchant = create(:merchant, user: other_user)
    create_list(:transaction, 5, user: other_user, merchant: other_user_merchant, account: other_user_account)

    valid_transaction_ids = transactions.map { |a| a.id }

    # Act
    transactions = Transactions::List::call(user: Users::SessionUser.new(user.id))

    # Assert
    assert_equal 5, transactions.length
    assert_equal valid_transaction_ids, transactions.map { |a| a.id }
  end
end
