# frozen_string_literal: true
require "test_helper"

class TransactionsGetTest < ActiveSupport::TestCase
  test "Should get transaction" do
    # Arrange
    transaction = create(:transaction)

    # Act
    result = Transactions::Get::call(transaction_id: transaction.id, user: Users::SessionUser.new(transaction.user.id))

    # Assert
    assert_equal transaction.id, result.id
    assert_in_delta transaction.date, result.date
    assert_equal transaction.merchant_id, result.merchant_id
    assert_equal transaction.account_id, result.account_id
    assert_equal transaction.country, result.country
    assert_equal transaction.currency, result.currency
  end

  test "Should throw if the account belongs to another user" do
    # Arrange
    transaction = create(:transaction)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::Get::call(transaction_id: transaction.id, user: Users::SessionUser.new("some-user"))
    end
  end
end
