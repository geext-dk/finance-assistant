# frozen_string_literal: true

require "test_helper"

class TransactionsUpdateTest < ActiveSupport::TestCase
  test "Should update transaction" do
    # Arrange
    transaction = create(:transaction, date: Time.utc(2022, 1, 1, 0, 0, 0, 0))

    # Act
    result = Transactions::Update::call(
      transaction_id: transaction.id,
      date: Time.utc(2023, 1, 1, 0, 0, 0, 0),
      user: Users::SessionUser.new(transaction.user.id))

    # Assert
    transaction = Transaction.find(transaction.id)
    assert_equal transaction, result
    assert_equal Time.utc(2023, 1, 1, 0, 0, 0, 0), result.date
  end

  test "Should throw if the account belongs to another user" do
    # Arrange
    transaction = create(:transaction)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::Update::call(
        transaction_id: transaction.id,
        date: Time.utc(2023, 1, 1, 0, 0, 0, 0),
        user: Users::SessionUser.new('another-user'))
    end
  end

  test "Should throw if the input data is invalid" do
    # Arrange
    transaction = create(:transaction)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::Update::call(
        transaction_id: transaction.id, date: nil,
        user: Users::SessionUser.new(transaction.user.id))
    end
  end
end
