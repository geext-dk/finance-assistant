# frozen_string_literal: true
require "test_helper"

class AccountsGetTest < ActiveSupport::TestCase
  test "Should get account" do
    # Arrange
    account = create(:account)

    # Act
    result = Accounts::Get::call(account_id: account.id, user: Users::SessionUser.new(account.user.id))

    # Assert
    assert_equal account.id, result.id
    assert_equal account.name, result.name
    assert_equal account.currency, result.currency
  end

  test "Should throw if the account is archived" do
    # Arrange
    account = create(:account, archived_at: Time.now.utc)

    # Act & Assert
    assert_raises NotFoundError do
      Accounts::Get::call(account_id: account.id, user: Users::SessionUser.new(account.user.id))
    end
  end

  test "Should throw if the account belongs to another user" do
    # Arrange
    account = create(:account)

    # Act & Assert
    assert_raises NotFoundError do
      Accounts::Get::call(account_id: account.id, user: Users::SessionUser.new("some-user"))
    end
  end
end
