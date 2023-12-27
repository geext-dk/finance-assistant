# frozen_string_literal: true

require "test_helper"

class TransactionsCreateTest < ActiveSupport::TestCase
  test "Should create a transaction" do
    # Arrange
    user = create(:user)
    merchant = create(:merchant, user: user)
    account = create(:account, user: user)
    transaction_date = Time.now.utc

    # Act
    result = Transactions::Create::call(
      merchant_id: merchant.id,
      account_id: account.id,
      date: transaction_date,
      user: Users::SessionUser.new(user.id))

    # Assert
    transaction = Transaction.find(result.id)
    assert_equal result, transaction
    assert_in_delta transaction_date, transaction.date
    assert_equal merchant.id, transaction.merchant_id
    assert_equal user.id, transaction.user_id
    assert_equal account.id, transaction.account_id
    assert_equal merchant.country, transaction.country
    assert_equal account.currency, transaction.currency
  end

  test "Should raise when no merchant passed" do
    # Arrange
    user = create(:user)
    account = create(:account, user: user)
    transaction_date = Time.now.utc

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::Create::call(
        merchant_id: nil,
        account_id: account.id,
        date: transaction_date,
        user: Users::SessionUser.new(user.id))
    end
  end

  test "Should raise when another users merchant passed" do
    # Arrange
    user = create(:user)
    account = create(:account, user: user)
    transaction_date = Time.now.utc

    other_user = create(:user)
    other_user_merchant = create(:merchant, user: other_user)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::Create::call(
        merchant_id: other_user_merchant.id,
        account_id: account.id,
        date: transaction_date,
        user: Users::SessionUser.new(user.id))
    end
  end

  test "Should raise when no account passed" do
    # Arrange
    user = create(:user)
    merchant = create(:merchant, user: user)
    transaction_date = Time.now.utc

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::Create::call(
        merchant_id: merchant.id,
        account_id: nil,
        date: transaction_date,
        user: Users::SessionUser.new(user.id))
    end
  end

  test "Should raise when another users account passed" do
    # Arrange
    user = create(:user)
    merchant = create(:merchant, user: user)
    transaction_date = Time.now.utc

    other_user = create(:user)
    other_user_account = create(:account, user: other_user)

    # Act & Assert
    assert_raises NotFoundError do
      Transactions::Create::call(
        merchant_id: merchant.id,
        account_id: other_user_account.id,
        date: transaction_date,
        user: Users::SessionUser.new(user.id))
    end
  end

  test "Should raise when no date passed" do
    # Arrange
    user = create(:user)
    account = create(:account, user: user)
    merchant = create(:merchant, user: user)

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::Create::call(
        merchant_id: merchant.id,
        account_id: account.id,
        date: nil,
        user: Users::SessionUser.new(user.id))
    end
  end

  test "Should raise when the user is unknown" do
    # Arrange
    user = create(:user)
    account = create(:account, user: user)
    merchant = create(:merchant, user: user)
    transaction_date = Time.now.utc

    # Act & Assert
    assert_raises ApplicationError do
      Transactions::Create::call(
        merchant_id: merchant.id,
        account_id: account.id,
        date: transaction_date,
        user: Users::SessionUser.new(nil))
    end
  end
end
