# frozen_string_literal: true
require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "Should be valid when fields are defined" do
    # Arrange
    transaction = create_valid_transaction

    # Act
    valid = transaction.valid?

    # Assert
    assert valid
  end

  test "Should validate all required fields and associations" do
    # Arrange
    transaction = Transaction.new

    # Act
    valid = transaction.valid?

    # Assert
    assert_not valid
    assert_includes transaction.errors[:account], "must exist"
    assert_includes transaction.errors[:user], "must exist"
    assert_includes transaction.errors[:merchant], "must exist"
    assert_includes transaction.errors[:currency], "can't be blank"
    assert_includes transaction.errors[:country], "can't be blank"
    assert_includes transaction.errors[:date], "can't be blank"
  end

  test "Should validate country" do
    # Arrange
    transaction = create_valid_transaction

    transaction.country = "invalid-country"

    # Act
    valid = transaction.valid?

    # Assert
    assert_not valid
    assert_includes transaction.errors[:country], "is invalid"
  end

  test "Should validate currency" do
    # Arrange
    transaction = create_valid_transaction

    transaction.currency = "invalid-currency"

    # Act
    valid = transaction.valid?

    # Assert
    assert_not valid
    assert_includes transaction.errors[:currency], "is invalid"
  end

  def create_valid_transaction
    transaction = Transaction.new(
      merchant_id: 'merchant-id',
      account_id: 'account-id',
      user_id: 'user-id',
      country: 'SE',
      currency: 'SEK',
      date: Time.now.utc
    )

    transaction.account = Account.new
    transaction.merchant = Merchant.new
    transaction.user = User.new

    transaction
  end
end
