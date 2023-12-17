# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "Should be valid when fields are defined" do
    # Arrange
    account = create_valid_account

    # Act
    valid = account.valid?

    # Assert
    assert valid
  end

  test "Should validate all required fields and associations" do
    # Arrange
    account = Account.new

    # Act
    valid = account.valid?

    # Assert
    assert_not valid
    assert_includes account.errors[:user], "must exist"
    assert_includes account.errors[:name], "can't be blank"
    assert_includes account.errors[:currency], "can't be blank"
  end

  test "Should validate currency" do
    # Arrange
    account = create_valid_account

    account.currency = "invalid-currency"

    # Act
    valid = account.valid?

    # Assert
    assert_not valid
    assert_includes account.errors[:currency], "is invalid"
  end

  def create_valid_account
    account = Account.new(
      user_id: 'user-id',
      name: 'Name',
      currency: 'SEK'
    )

    account.user = User.new

    account
  end
end
